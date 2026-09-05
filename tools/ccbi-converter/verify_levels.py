#!/usr/bin/env python3
"""Rigorously verify converted Wicked Little Devil level JSON.

Runs structural, semantic and gameplay-plausibility checks over every
`world-<W>-level-<L>.json` produced by `convert_ccbi.py` and reports
failures (hard problems) and warnings (outliers worth a human look).
"""
from __future__ import annotations

import argparse
import json
import math
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

LEVEL_PATTERN = re.compile(r"world-(\d+)-level-(\d+)\.json$")

REQUIRED_TOP_LEVEL = [
    "schemaVersion",
    "source",
    "coordinateSpace",
    "metadata",
    "playerSpawn",
    "goal",
    "platforms",
    "collectables",
    "enemies",
    "projectileSpawners",
    "triggers",
    "tips",
    "diagnostics",
]

OBJECT_COLLECTIONS = ["platforms", "collectables", "enemies", "triggers", "tips"]

# Generous horizontal envelope: sprites are centre-anchored and the original
# levels deliberately let movers overhang the 320pt screen.
X_MIN = -200.0
X_MAX = 520.0
# Vertical climber: nothing should sit below the floor or above the top trigger.
Y_MIN = -50.0
Y_TOP_TOLERANCE = 40.0

KNOWN_PLATFORM_KINDS = {
    "normal", "boost", "moving", "switch", "toggleTarget",
    "breakable", "movingBreakable", "timed", "goal",
}
KNOWN_ENEMY_KINDS = {"bat", "mine", "bubble", "rocketLauncher", "blackHole", "angelLaser"}
KNOWN_COLLECTABLE_KINDS = {"small", "big", "halo"}


class LevelReport:
    def __init__(self, name: str) -> None:
        self.name = name
        self.failures: list[str] = []
        self.warnings: list[str] = []
        self.stats: dict[str, Any] = {}

    def fail(self, message: str) -> None:
        self.failures.append(message)

    def warn(self, message: str) -> None:
        self.warnings.append(message)

    @property
    def status(self) -> str:
        if self.failures:
            return "fail"
        if self.warnings:
            return "warn"
        return "pass"


def bad_number(value: Any) -> bool:
    return isinstance(value, float) and (math.isnan(value) or math.isinf(value))


def find_bad_numbers(node: Any, path: str = "") -> list[str]:
    problems: list[str] = []
    if isinstance(node, dict):
        for key, value in node.items():
            problems.extend(find_bad_numbers(value, f"{path}.{key}" if path else key))
    elif isinstance(node, list):
        for index, value in enumerate(node):
            problems.extend(find_bad_numbers(value, f"{path}[{index}]"))
    elif bad_number(node):
        problems.append(path)
    return problems


def check_position(report: LevelReport, label: str, position: Any, top_y: float | None, playable: bool) -> tuple[float, float] | None:
    if not isinstance(position, dict) or "x" not in position or "y" not in position:
        report.fail(f"{label}: missing position")
        return None
    x, y = position.get("x"), position.get("y")
    if x is None or y is None:
        report.fail(f"{label}: null coordinate ({x}, {y})")
        return None
    if not playable:
        # Parked palette objects legitimately sit far off-screen; only guard
        # against values that indicate a decoding failure rather than intent.
        if not (-2000.0 <= x <= 2000.0) or not (-2000.0 <= y <= 20000.0):
            report.fail(f"{label}: parked object at absurd coordinate ({x}, {y})")
        return (x, y)
    if not (X_MIN <= x <= X_MAX):
        report.fail(f"{label}: x out of plausible range ({x})")
    if y < Y_MIN:
        report.fail(f"{label}: y below floor ({y})")
    if top_y is not None and y > top_y + Y_TOP_TOLERANCE:
        report.warn(f"{label}: y {y} sits above topBoundaryY {top_y}")
    return (x, y)


def verify_level(path: Path) -> LevelReport:
    report = LevelReport(path.stem)

    try:
        raw_text = path.read_text(encoding="utf-8")
    except OSError as exc:
        report.fail(f"unreadable: {exc}")
        return report

    try:
        data = json.loads(raw_text)
    except json.JSONDecodeError as exc:
        report.fail(f"invalid JSON: {exc}")
        return report

    # Reject JSON that decodes only because Python tolerates NaN/Infinity.
    for literal in ("NaN", "Infinity", "-Infinity"):
        if re.search(rf"(?<![\w\"]){literal}(?![\w\"])", raw_text):
            report.fail(f"non-standard JSON literal {literal} present")

    missing_keys = [key for key in REQUIRED_TOP_LEVEL if key not in data]
    for key in missing_keys:
        report.fail(f"missing top-level key '{key}'")
    if missing_keys:
        # Nothing below can be evaluated meaningfully without the full shape.
        return report

    for bad_path in find_bad_numbers(data):
        report.fail(f"NaN/Inf value at {bad_path}")

    match = LEVEL_PATTERN.search(path.name)
    source = data["source"]
    if match:
        if source.get("world") != int(match.group(1)) or source.get("level") != int(match.group(2)):
            report.fail(
                f"source world/level {source.get('world')}/{source.get('level')} "
                f"disagrees with filename"
            )

    metadata = data["metadata"]
    top_y = metadata.get("topBoundaryY")
    if top_y is None:
        report.fail("metadata.topBoundaryY is null (no level top boundary)")
    elif top_y <= 0:
        report.fail(f"metadata.topBoundaryY not positive ({top_y})")

    if not metadata.get("theme"):
        report.warn("metadata.theme missing")
    if metadata.get("timeLimitSeconds") not in (30, 60, 90):
        report.fail(f"unexpected timeLimitSeconds {metadata.get('timeLimitSeconds')}")
    # Mirror GameScene.m: 30s default, 60s above 2500, 90s above 5000.
    if top_y is not None:
        expected_limit = 90 if top_y > 5000 else 60 if top_y > 2500 else 30
        if metadata.get("timeLimitSeconds") != expected_limit:
            report.fail(
                f"timeLimitSeconds {metadata.get('timeLimitSeconds')} "
                f"!= legacy rule {expected_limit} for top {top_y}"
            )

    viewport = data["coordinateSpace"].get("logicalViewport", {})
    width = viewport.get("width")
    height = viewport.get("height")
    if not width or not height:
        report.fail("coordinateSpace.logicalViewport incomplete")

    spawn = data["playerSpawn"]
    if not isinstance(spawn, dict) or spawn.get("x") is None or spawn.get("y") is None:
        report.fail("playerSpawn missing or incomplete")
    else:
        if width and not (0 < spawn["x"] < width):
            report.fail(f"playerSpawn.x {spawn['x']} outside viewport width {width}")
        if not (0 < spawn["y"] < 200):
            report.fail(f"playerSpawn.y {spawn['y']} implausible for a bottom-of-level spawn")

    platforms = data["platforms"]
    collectables = data["collectables"]
    enemies = data["enemies"]
    triggers = data["triggers"]

    for name in OBJECT_COLLECTIONS + ["projectileSpawners"]:
        if not isinstance(data[name], list):
            report.fail(f"'{name}' is not a list")

    if not platforms:
        report.fail("no platforms — level is unplayable")
    elif not [p for p in platforms if p.get("playable", True)]:
        report.fail("no reachable platforms — level is unplayable")

    ids = [item.get("id") for item in platforms + collectables + enemies + triggers]
    duplicate_ids = [key for key, count in Counter(ids).items() if count > 1]
    if duplicate_ids:
        report.fail(f"duplicate object ids: {duplicate_ids[:5]}")
    if any(key is None for key in ids):
        report.fail("object with missing id")

    goal = data["goal"]
    goal_platforms = [p for p in platforms if p.get("legacyTag") == 100]
    if not goal_platforms:
        report.fail("no finish platform (legacyTag 100) — level cannot be completed")
    elif len(goal_platforms) > 1:
        report.warn(f"{len(goal_platforms)} finish platforms found")
    if goal.get("platformId") is None or goal.get("position") is None:
        report.fail("goal block not populated")
    elif goal_platforms and goal["platformId"] != goal_platforms[0]["id"]:
        report.fail("goal.platformId does not match the first finish platform")
    if goal_platforms and not goal_platforms[0].get("playable", True):
        report.fail("finish platform is parked off-screen — level cannot be completed")

    top_triggers = [t for t in triggers if t.get("legacyTag") == 100]
    if not top_triggers:
        report.fail("no level-top trigger (legacyTag 100)")
    elif triggers and triggers[0].get("legacyTag") != 100:
        # GameScene.m reads triggers[0] to size the camera boundary.
        report.fail("first trigger is not the level-top trigger")
    if top_y is not None and top_triggers:
        if abs(top_triggers[0]["position"]["y"] - top_y) > 0.01:
            report.fail("metadata.topBoundaryY disagrees with the first top trigger")

    kind_counts: Counter[str] = Counter(item.get("kind") for item in collectables)
    playable_kind_counts: Counter[str] = Counter(
        item.get("kind") for item in collectables if item.get("playable", True)
    )
    if playable_kind_counts.get("big", 0) < 1:
        report.fail("no reachable BigCollectable — didWin requires bigcollected >= 1, level unwinnable")
    for kind in kind_counts:
        if kind not in KNOWN_COLLECTABLE_KINDS:
            report.fail(f"unknown collectable kind '{kind}'")

    max_object_y = None
    parked_counts: Counter[str] = Counter()
    for collection_name in OBJECT_COLLECTIONS:
        for item in data[collection_name]:
            label = f"{collection_name}/{item.get('id')}"
            playable = item.get("playable")
            if not isinstance(playable, bool):
                report.fail(f"{label}: missing 'playable' flag")
                playable = True
            if not playable:
                parked_counts[collection_name] += 1
            resolved = check_position(report, label, item.get("position"), top_y, playable)
            if resolved and playable and (max_object_y is None or resolved[1] > max_object_y):
                max_object_y = resolved[1]
            item_size = item.get("size")
            if not isinstance(item_size, dict):
                report.fail(f"{label}: missing size")
                continue
            item_width, item_height = item_size.get("width"), item_size.get("height")
            if item_width is None or item_height is None:
                report.fail(f"{label}: null size")
            elif item_width <= 0 or item_height <= 0:
                report.fail(f"{label}: non-positive size {item_width}x{item_height}")
            elif item_width > 1000 or item_height > 1000:
                report.warn(f"{label}: very large size {item_width}x{item_height}")

    for platform in platforms:
        if platform.get("kind") not in KNOWN_PLATFORM_KINDS:
            report.fail(f"platform {platform.get('id')} unmapped kind '{platform.get('kind')}' (legacyTag {platform.get('legacyTag')})")
        if not platform.get("spriteFrame"):
            report.warn(f"platform {platform.get('id')} has no spriteFrame")

    for enemy in enemies:
        if enemy.get("kind") not in KNOWN_ENEMY_KINDS:
            report.fail(f"enemy {enemy.get('id')} unmapped kind '{enemy.get('kind')}' (legacyTag {enemy.get('legacyTag')})")

    launcher_count = sum(1 for enemy in enemies if enemy.get("kind") == "rocketLauncher")
    if launcher_count != len(data["projectileSpawners"]):
        report.fail(
            f"projectileSpawners {len(data['projectileSpawners'])} "
            f"!= rocketLauncher enemies {launcher_count}"
        )

    unknown_nodes = data["diagnostics"].get("unknownNodes") or []
    if unknown_nodes:
        report.fail(f"unhandled node classes: {sorted({n['className'] for n in unknown_nodes})}")
    if data["diagnostics"].get("rawRootClass") != "GameLayer":
        report.warn(f"unexpected root class {data['diagnostics'].get('rawRootClass')}")

    reported_parked = data["diagnostics"].get("parkedObjects") or {}
    for collection_name in OBJECT_COLLECTIONS:
        if reported_parked.get(collection_name, 0) != parked_counts.get(collection_name, 0):
            report.fail(
                f"diagnostics.parkedObjects.{collection_name} "
                f"{reported_parked.get(collection_name)} != counted {parked_counts.get(collection_name, 0)}"
            )
    if data["diagnostics"].get("parkedObjectTotal") != sum(parked_counts.values()):
        report.fail("diagnostics.parkedObjectTotal disagrees with the flagged objects")

    timeline_overrides = data["diagnostics"].get("timelineOverrides") or []
    if timeline_overrides:
        report.warn(
            f"{len(timeline_overrides)} autoplay keyframe(s) override static properties: "
            f"{sorted({o['property'] for o in timeline_overrides})}"
        )

    playable_metadata = metadata.get("playableCollectables") or {}
    for kind in KNOWN_COLLECTABLE_KINDS:
        if playable_metadata.get(kind) != playable_kind_counts.get(kind, 0):
            report.fail(
                f"metadata.playableCollectables.{kind} {playable_metadata.get(kind)} "
                f"!= counted {playable_kind_counts.get(kind, 0)}"
            )

    validation = data.get("validation")
    if validation and validation.get("status") not in (None, "pass"):
        report.fail(f"ccb cross-check {validation.get('status')}: {validation.get('mismatches', [])[:3]}")

    if top_y is not None and max_object_y is not None and top_y < max_object_y - Y_TOP_TOLERANCE:
        report.warn(f"topBoundaryY {top_y} is below the tallest object at {max_object_y}")

    # Outlier heuristics — genuinely sparse levels are legal (tutorials) but flagged.
    playable_platforms = sum(1 for p in platforms if p.get("playable", True))
    playable_collectables = sum(1 for c in collectables if c.get("playable", True))
    if playable_platforms < 5:
        report.warn(f"only {playable_platforms} reachable platforms")
    if playable_collectables < 4:
        report.warn(f"only {playable_collectables} reachable collectables")
    if top_y is not None and top_y < 400:
        report.warn(f"very short level (top {top_y})")

    report.stats = {
        "world": source.get("world"),
        "level": source.get("level"),
        "platforms": len(platforms),
        "playablePlatforms": playable_platforms,
        "collectables": len(collectables),
        "playableCollectables": playable_collectables,
        "collectablesSmall": playable_kind_counts.get("small", 0),
        "collectablesBig": playable_kind_counts.get("big", 0),
        "collectablesHalo": playable_kind_counts.get("halo", 0),
        "enemies": len(enemies),
        "playableEnemies": sum(1 for e in enemies if e.get("playable", True)),
        "triggers": len(triggers),
        "tips": len(data["tips"]),
        "projectileSpawners": len(data["projectileSpawners"]),
        "parkedObjects": sum(parked_counts.values()),
        "topBoundaryY": top_y,
        "timeLimitSeconds": metadata.get("timeLimitSeconds"),
        "nodeCount": metadata.get("nodeCount"),
        "maxObjectY": max_object_y,
        "platformKinds": dict(Counter(p.get("kind") for p in platforms)),
        "enemyKinds": dict(Counter(e.get("kind") for e in enemies)),
        "ccbValidation": (validation or {}).get("status"),
    }
    return report


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("levels_dir", type=Path, help="directory of converted level JSON")
    parser.add_argument("--expected-count", type=int, help="fail if a different number of levels is found")
    parser.add_argument("--report-file", type=Path, help="write the full machine-readable report here")
    parser.add_argument("--quiet", action="store_true", help="only print failures and warnings")
    args = parser.parse_args(argv)

    paths = sorted(args.levels_dir.glob("*.json"), key=lambda p: (
        int(LEVEL_PATTERN.search(p.name).group(1)) if LEVEL_PATTERN.search(p.name) else 0,
        int(LEVEL_PATTERN.search(p.name).group(2)) if LEVEL_PATTERN.search(p.name) else 0,
    ))
    paths = [p for p in paths if LEVEL_PATTERN.search(p.name)]
    if not paths:
        print(f"no level JSON found in {args.levels_dir}", file=sys.stderr)
        return 2

    reports = [verify_level(path) for path in paths]
    by_status = Counter(report.status for report in reports)

    per_world: dict[int, dict[str, Any]] = defaultdict(lambda: defaultdict(int))
    for report in reports:
        world = report.stats.get("world")
        if world is None:
            continue
        bucket = per_world[world]
        bucket["levels"] += 1
        for key in ("platforms", "playablePlatforms", "collectables", "playableCollectables",
                    "collectablesSmall", "collectablesBig", "collectablesHalo", "enemies",
                    "playableEnemies", "triggers", "tips", "projectileSpawners", "parkedObjects"):
            bucket[key] += report.stats.get(key, 0)

    for report in reports:
        if args.quiet and report.status == "pass":
            continue
        print(f"[{report.status.upper():4s}] {report.name}")
        for message in report.failures:
            print(f"    FAIL {message}")
        for message in report.warnings:
            print(f"    WARN {message}")

    print(f"\n{len(reports)} levels: {by_status.get('pass', 0)} pass, "
          f"{by_status.get('warn', 0)} warn, {by_status.get('fail', 0)} fail")

    if args.expected_count is not None and len(reports) != args.expected_count:
        print(f"expected {args.expected_count} levels, found {len(reports)}", file=sys.stderr)
        return 2

    if args.report_file:
        args.report_file.parent.mkdir(parents=True, exist_ok=True)
        args.report_file.write_text(
            json.dumps(
                {
                    "totals": {
                        "levels": len(reports),
                        "pass": by_status.get("pass", 0),
                        "warn": by_status.get("warn", 0),
                        "fail": by_status.get("fail", 0),
                    },
                    "perWorld": {str(k): dict(v) for k, v in sorted(per_world.items())},
                    "levels": [
                        {
                            "name": report.name,
                            "status": report.status,
                            "failures": report.failures,
                            "warnings": report.warnings,
                            **report.stats,
                        }
                        for report in reports
                    ],
                },
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )

    return 1 if by_status.get("fail") else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

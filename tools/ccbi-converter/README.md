# CCBI level converter

Standalone Python 3 CLI for migrating Wicked Little Devil level data from compiled CocosBuilder `.ccbi` files into Swift/SpriteKit-friendly JSON.

## What it does

- Parses the bundled CocosBuilder binary format directly from `the vendored CCBReader (deleted with the 2012 project; see git history)` semantics:
  - header + string cache
  - variable-length encoded ints
  - compact float encoding
  - node tree recursion
  - per-node properties and animation sequence metadata
- Resolves relative CocosBuilder positions/sizes into point-space for a chosen logical viewport.
- Flattens gameplay objects into typed arrays for Swift `Codable` models:
  - `platforms`
  - `collectables` (`small`, `big`, `halo`)
  - `enemies`
  - `projectileSpawners` (derived from rocket-launcher enemies)
  - `triggers`
  - `tips`
- Optionally embeds the raw parsed node tree for debugging.
- Optionally cross-checks each `.ccbi` against the matching human-readable `.ccb` file in `Resources/DATA/LEVEL BUILDER/`.

## Usage

From the repo root:

```bash
python3 tools/ccbi-converter/convert_ccbi.py \
  'legacy-reference/Resources/DATA/LEVELS/world-1-level-*.ccbi' \
  --output-dir tools/ccbi-converter/output \
  --validate-with-ccb
```

Representative validation run:

```bash
python3 tools/ccbi-converter/convert_ccbi.py \
  'legacy-reference/Resources/DATA/LEVELS/world-1-level-*.ccbi' \
  'legacy-reference/Resources/DATA/LEVELS/world-3-level-17.ccbi' \
  'legacy-reference/Resources/DATA/LEVELS/world-20-level-1.ccbi' \
  --output-dir tools/ccbi-converter/samples \
  --summary-file tools/ccbi-converter/samples/validation-summary.json \
  --validate-with-ccb
```

### Regenerating the shipped level data

The Swift app reads its levels from `WickedLittleDevilSwift/Resources/Levels/`.
Regenerate all 91 of them, then cross-check and verify:

```bash
# 1. Shipped game data — no `validation` block, so nothing build-time-only
#    ends up in the app bundle.
python3 tools/ccbi-converter/convert_ccbi.py \
  'legacy-reference/Resources/DATA/LEVELS/*.ccbi' \
  --output-dir WickedLittleDevilSwift/Resources/Levels

# 2. Cross-check every decoded binary against its .ccb plist source.
python3 tools/ccbi-converter/convert_ccbi.py \
  'legacy-reference/Resources/DATA/LEVELS/*.ccbi' \
  --summary-only --validate-with-ccb \
  --summary-file tools/ccbi-converter/ccb-crosscheck.json

# 3. Verify the emitted JSON is structurally and semantically sane.
python3 tools/ccbi-converter/verify_levels.py \
  WickedLittleDevilSwift/Resources/Levels \
  --expected-count 91 \
  --report-file tools/ccbi-converter/verification-report.json
```

## Verifying converted levels

`verify_levels.py` is the acceptance gate for converted level data. It exits
non-zero if anything fails, so it is safe to wire into CI. For each level it
checks that the JSON parses under strict rules (no `NaN`/`Infinity` literals),
that every required key is present and correctly typed, that coordinates are
plausible, that the level is winnable (a reachable finish platform plus at
least one reachable `BigCollectable`), that `topBoundaryY` agrees with the
tallest playable object, that `timeLimitSeconds` matches the legacy rule in
`GameScene.m`, and that object kinds are all recognised. It also re-derives
the parked-object and collectable counts and cross-checks them against the
values the converter recorded, so the two tools cannot silently drift apart.

```bash
python3 tools/ccbi-converter/verify_levels.py WickedLittleDevilSwift/Resources/Levels \
  --expected-count 91 --report-file tools/ccbi-converter/verification-report.json
```

Exit codes: `0` all levels pass, `1` at least one level failed, `2` no input
found or the file count did not match `--expected-count`.

## Important assumptions

- Output coordinates are **resolved point coordinates**, not raw CCB percentages.
- Default logical viewport is `320x480`, matching the non-iPhone-5 branch in game code.
- Use `--viewport 320x568` if you want the taller-device resolution instead.
- The converter does **not** modify anything under `legacy-reference/`.
- Percent-relative positions and sizes are truncated **toward zero**, reproducing
  the `(int)` cast in `CCNode+CCBRelativePositioning.m`. Do not "improve" this to
  rounding: the original game's collision and landing behaviour is built on the
  truncated values, and several levels use negative percentages where truncation
  and flooring disagree.

## Parked ("off-screen palette") objects

Worlds 3 and 4 — and a handful of levels elsewhere — were authored from a
CocosBuilder template that keeps a palette of spare objects parked outside the
play area, typically one of each platform variant sitting off to the left or
right and below the floor. They are real objects in the original data and the
original game does load them, but they are unreachable: `GameScene.m` drives the
player's `x` straight from the touch position, so the player is confined to
`0...320`, and `GameLayer`'s update culls anything that falls far enough below
the camera.

Every gameplay object therefore carries a `playable` boolean:

```
playable = (x + width/2 > 0) && (x - width/2 < viewportWidth)
```

A horizontal test alone is enough to separate the two groups cleanly — every
object below the floor is also horizontally off-screen, and the lowest playable
object across all 91 levels sits at `y = 27.1`.

Consumers should render and simulate only `playable` objects. The parked ones
are retained so the JSON stays a faithful representation of the source data,
and are summarised in `diagnostics.parkedObjects`.

## JSON schema

Top-level shape:

- `schemaVersion` — currently `1.1.0`
- `source` — source file + world/level numbers
- `coordinateSpace` — resolved viewport metadata
- `metadata` — theme/background/time-limit/level height, plus
  `playableCollectables` (`small`/`big`/`halo` counts excluding parked objects)
- `playerSpawn` — derived from `PlayerLayer.m`
- `goal` — finish platform summary
- `platforms[]`
- `collectables[]`
- `enemies[]`
- `projectileSpawners[]`
- `triggers[]`
- `tips[]`
- `diagnostics` — unknown nodes / parser hints, plus `parkedObjects`,
  `parkedObjectTotal` and `timelineOverrides`
- optional `nodeTree` — raw parsed CCBI node graph

Every entry in `platforms`, `collectables`, `enemies`, `triggers` and `tips`
carries a `playable` flag (see above).

`diagnostics.timelineOverrides` lists any autoplay-timeline keyframe at `t=0`
whose value differs from the node's static property. `CCBReader` runs the
autoplay sequence with `tweenDuration:0` immediately after load, so such a
keyframe would silently override the static value the converter emitted. Across
the shipped catalogue this list is empty on every level — it exists as a
regression guard, and a non-empty list means the converted coordinates for that
node are wrong.

### Example

```json
{
  "schemaVersion": "1.0.0",
  "source": {
    "ccbi": "legacy-reference/Resources/DATA/LEVELS/world-1-level-20.ccbi",
    "world": 1,
    "level": 20
  },
  "coordinateSpace": {
    "kind": "points",
    "logicalViewport": { "width": 320.0, "height": 480.0 }
  },
  "metadata": {
    "theme": "hell",
    "backgroundImage": "bg-world-1.png",
    "timeLimitSeconds": 60,
    "topBoundaryY": 3715.867,
    "nodeCount": 339,
    "timelineNames": ["Default Timeline"],
    "autoPlaySequenceId": 0
  },
  "playerSpawn": { "x": 160.0, "y": 60.0 },
  "goal": {
    "requiresBigCollectables": 1,
    "platformId": "platform-003",
    "position": { "x": 154.0, "y": 3517.867 }
  },
  "platforms": [
    {
      "id": "platform-007",
      "position": { "x": 38.0, "y": 494.0 },
      "size": { "width": 64.0, "height": 19.0 },
      "rotationDegrees": 0.0,
      "spriteFrame": "platform-moving.png",
      "spriteSheet": "IngameSprites.plist",
      "legacyTag": 33,
      "kind": "moving",
      "behavior": {
        "mode": "movingHorizontal",
        "offset": { "x": 100, "y": 0 },
        "durationSeconds": 2.0
      }
    }
  ],
  "collectables": [
    {
      "id": "collectable-001",
      "position": { "x": 293.0, "y": 711.488 },
      "size": { "width": 36.0, "height": 36.0 },
      "kind": "big",
      "value": 1
    }
  ],
  "enemies": [
    {
      "id": "enemy-001",
      "position": { "x": 40.0, "y": 980.055 },
      "size": { "width": 75.0, "height": 26.0 },
      "legacyTag": 1,
      "kind": "bat",
      "behavior": {
        "mode": "horizontalPatrol",
        "direction": "right",
        "speedPerFrame": 1.0,
        "wrapsAtViewportEdge": true
      }
    }
  ],
  "projectileSpawners": [],
  "triggers": [
    {
      "id": "trigger-001",
      "position": { "x": 157.582, "y": 3715.867 },
      "size": { "width": 448.489, "height": 14.673 },
      "legacyTag": 100,
      "kind": "levelTopBoundary"
    }
  ]
}
```

## Gameplay mapping notes

### Platforms

Tags are mapped from `Objects/Platform.m`:

- `null/-1/0` normal
- `1` jump boost
- `2/22` vertical movers
- `3/33` horizontal movers
- `5` toggle switch
- `51/52` toggle targets
- `6` breakable
- `66/663` moving breakables
- `7/71/72/73` timed variants (supported in schema, not seen in sampled files)
- `100` finish platform

### Enemies

Tags are mapped from `Objects/Enemy.m`:

- `1/101` bat patrol
- `2` mine
- `22/223` moving mines
- `3` bubble lift
- `4` rocket launcher
- `5/6` supported in the schema from code comments, but not present in sampled level files

## Validation strategy

The repo includes matching `.ccb` sources in `legacy-reference/Resources/DATA/LEVEL BUILDER/`.

With `--validate-with-ccb`, the converter compares:

- node count
- preorder node classes
- gameplay-relevant properties (`position`, `contentSize`, `scale`, `tag`, `displayFrame`, `opacity`, `color`, etc.)

This is the quickest way to confirm that the binary parse still matches the authoring source before converting the full catalog.

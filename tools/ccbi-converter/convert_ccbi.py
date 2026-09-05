#!/usr/bin/env python3
"""Convert CocosBuilder .ccbi level files into Swift-friendly JSON."""
from __future__ import annotations

import argparse
import json
import math
import plistlib
import re
import struct
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable
import glob as globlib

CCB_VERSION = 4

PROP_TYPE_NAMES = {
    0: "Position",
    1: "Size",
    2: "Point",
    3: "PointLock",
    4: "ScaleLock",
    5: "Degrees",
    6: "Integer",
    7: "Float",
    8: "FloatVar",
    9: "Check",
    10: "SpriteFrame",
    11: "Texture",
    12: "Byte",
    13: "Color3",
    14: "Color4FVar",
    15: "Flip",
    16: "Blendmode",
    17: "FntFile",
    18: "Text",
    19: "FontTTF",
    20: "IntegerLabeled",
    21: "Block",
    22: "Animation",
    23: "CCBFile",
    24: "String",
    25: "BlockCCControl",
    26: "FloatScale",
}

POSITION_TYPES = {
    0: "relativeBottomLeft",
    1: "relativeTopLeft",
    2: "relativeTopRight",
    3: "relativeBottomRight",
    4: "percent",
    5: "multiplyResolution",
}

SIZE_TYPES = {
    0: "absolute",
    1: "percent",
    2: "relativeContainer",
    3: "horizontalPercent",
    4: "verticalPercent",
    5: "multiplyResolution",
}

PLATFORM_TAG_MAP: dict[int | None, dict[str, Any]] = {
    None: {"kind": "normal", "behavior": {"mode": "static"}},
    -1: {"kind": "normal", "behavior": {"mode": "static"}},
    0: {"kind": "normal", "behavior": {"mode": "static"}},
    1: {"kind": "boost", "behavior": {"mode": "jumpBoost", "jumpMultiplier": 1.95}},
    2: {"kind": "moving", "behavior": {"mode": "movingVertical", "offset": {"x": 0, "y": 100}, "durationSeconds": 2.0}},
    22: {"kind": "moving", "behavior": {"mode": "movingVertical", "offset": {"x": 0, "y": -100}, "durationSeconds": 2.0}},
    3: {"kind": "moving", "behavior": {"mode": "movingHorizontal", "offset": {"x": -100, "y": 0}, "durationSeconds": 2.0}},
    33: {"kind": "moving", "behavior": {"mode": "movingHorizontal", "offset": {"x": 100, "y": 0}, "durationSeconds": 2.0}},
    5: {"kind": "switch", "behavior": {"mode": "toggleSwitch", "controlsTags": [51, 52]}},
    51: {"kind": "toggleTarget", "behavior": {"mode": "toggleTarget", "group": 1, "initiallyEnabled": True}},
    52: {"kind": "toggleTarget", "behavior": {"mode": "toggleTarget", "group": 2, "initiallyEnabled": False}},
    6: {"kind": "breakable", "behavior": {"mode": "breakable", "health": 1.0, "fallDistance": 400, "fallDurationSeconds": 0.5}},
    66: {"kind": "movingBreakable", "behavior": {"mode": "movingHorizontalBreakable", "moveOffset": {"x": -100, "y": 0}, "moveDurationSeconds": 2.0, "health": 1.0, "fallDistance": 400, "fallDurationSeconds": 0.5}},
    663: {"kind": "movingBreakable", "behavior": {"mode": "movingHorizontalBreakable", "moveOffset": {"x": 100, "y": 0}, "moveDurationSeconds": 2.0, "health": 1.0, "fallDistance": 400, "fallDurationSeconds": 0.5}},
    7: {"kind": "timed", "behavior": {"mode": "timed", "durationSeconds": 5}},
    71: {"kind": "timed", "behavior": {"mode": "timed", "durationSeconds": 10}},
    72: {"kind": "timed", "behavior": {"mode": "timed", "durationSeconds": 15}},
    73: {"kind": "timed", "behavior": {"mode": "timed", "durationSeconds": 30}},
    100: {"kind": "goal", "behavior": {"mode": "finish", "requiresBigCollectables": 1, "completionDelaySeconds": 1.0}},
}

ENEMY_TAG_MAP: dict[int | None, dict[str, Any]] = {
    1: {"kind": "bat", "behavior": {"mode": "horizontalPatrol", "direction": "right", "speedPerFrame": 1.0, "wrapsAtViewportEdge": True}},
    101: {"kind": "bat", "behavior": {"mode": "horizontalPatrol", "direction": "left", "speedPerFrame": 1.0, "wrapsAtViewportEdge": True}},
    2: {"kind": "mine", "behavior": {"mode": "contactExplode"}},
    22: {"kind": "mine", "behavior": {"mode": "movingHorizontal", "offset": {"x": -100, "y": 0}, "durationSeconds": 2.0, "contactEffect": "explode"}},
    223: {"kind": "mine", "behavior": {"mode": "movingHorizontal", "offset": {"x": 100, "y": 0}, "durationSeconds": 2.0, "contactEffect": "explode"}},
    3: {"kind": "bubble", "behavior": {"mode": "carryPlayerUp", "verticalTravel": 250, "durationSeconds": 3.0, "tapToPop": True}},
    4: {"kind": "rocketLauncher", "behavior": {"mode": "proximityTriggeredProjectile", "triggerRadius": 30, "projectileSpeed": 400, "spawnX": 27, "verticalOffset": 300, "immunePowerup": 104}},
    5: {"kind": "blackHole", "behavior": {"mode": "teleport", "destinationChildTag": 1000}},
    6: {"kind": "angelLaser", "behavior": {"mode": "periodicAreaBlast", "cycleSeconds": 8.0}},
    None: {"kind": "unknown", "behavior": {"mode": "unknown"}},
}

COLLECTABLE_CLASS_MAP = {
    "Collectable": {"kind": "small", "value": 1},
    "BigCollectable": {"kind": "big", "value": 1},
    "HaloCollectable": {"kind": "halo", "value": 1},
}

WORLD_THEME_MAP = {
    1: {"theme": "hell", "backgroundImage": "bg-world-1.png"},
    2: {"theme": "underground", "backgroundImage": "bg-world-2.png"},
    3: {"theme": "ocean", "backgroundImage": "bg-world-3.png"},
    4: {"theme": "land", "backgroundImage": "bg-world-4.png"},
    11: {"theme": "bonus", "backgroundImage": "bg-world-1.png"},
    20: {"theme": "detective", "backgroundImage": "bg-world-20.png"},
}

MAGIC = b"ibcc"
LEVEL_PATTERN = re.compile(r"world-(\d+)-level-(\d+)\.ccbi$")
PAIR_PATTERN = re.compile(r"\{\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*\}")


def round_number(value: float | None, digits: int = 3) -> float | None:
    return None if value is None else round(float(value), digits)


def point(x: float, y: float) -> dict[str, float]:
    return {"x": round_number(x), "y": round_number(y)}


def size(width: float, height: float) -> dict[str, float]:
    return {"width": round_number(width), "height": round_number(height)}


@dataclass
class RawProperty:
    name: str
    type_id: int
    platform: int
    value: Any

    @property
    def type_name(self) -> str:
        return PROP_TYPE_NAMES.get(self.type_id, f"unknown-{self.type_id}")


@dataclass
class RawNode:
    class_name: str
    member_assignment_type: int = 0
    member_assignment_name: str | None = None
    js_controller_name: str | None = None
    properties: list[RawProperty] = field(default_factory=list)
    children: list["RawNode"] = field(default_factory=list)
    sequences: list[dict[str, Any]] = field(default_factory=list)

    def property_map(self) -> dict[str, RawProperty]:
        return {prop.name: prop for prop in self.properties}


@dataclass
class AffineTransform:
    a: float = 1.0
    b: float = 0.0
    c: float = 0.0
    d: float = 1.0
    tx: float = 0.0
    ty: float = 0.0

    def apply(self, x: float, y: float) -> tuple[float, float]:
        return (self.a * x + self.c * y + self.tx, self.b * x + self.d * y + self.ty)

    def concat(self, other: "AffineTransform") -> "AffineTransform":
        return AffineTransform(
            a=self.a * other.a + self.c * other.b,
            b=self.b * other.a + self.d * other.b,
            c=self.a * other.c + self.c * other.d,
            d=self.b * other.c + self.d * other.d,
            tx=self.a * other.tx + self.c * other.ty + self.tx,
            ty=self.b * other.tx + self.d * other.ty + self.ty,
        )


@dataclass
class ResolvedNode:
    raw: RawNode
    path: str
    class_name: str
    properties: dict[str, Any]
    position: tuple[float, float]
    world_position: tuple[float, float]
    content_size: tuple[float, float]
    world_size: tuple[float, float]
    rotation: float
    world_rotation: float
    scale: tuple[float, float]
    world_transform: AffineTransform
    children: list["ResolvedNode"]


class ParseError(RuntimeError):
    pass


class BinaryReader:
    def __init__(self, data: bytes) -> None:
        self.data = data
        self.current_byte = 0
        self.current_bit = 0

    def read_byte(self) -> int:
        value = self.data[self.current_byte]
        self.current_byte += 1
        return value

    def read_bool(self) -> bool:
        return bool(self.read_byte())

    def read_utf8(self) -> str:
        length = (self.read_byte() << 8) | self.read_byte()
        value = self.data[self.current_byte : self.current_byte + length].decode("utf-8")
        self.current_byte += length
        return value

    def get_bit(self) -> bool:
        value = bool(self.data[self.current_byte] & (1 << self.current_bit))
        self.current_bit += 1
        if self.current_bit >= 8:
            self.current_bit = 0
            self.current_byte += 1
        return value

    def align_bits(self) -> None:
        if self.current_bit:
            self.current_bit = 0
            self.current_byte += 1

    def read_int(self, sign: bool) -> int:
        num_bits = 0
        while not self.get_bit():
            num_bits += 1
        current = 0
        for bit_index in range(num_bits - 1, -1, -1):
            if self.get_bit():
                current |= 1 << bit_index
        current |= 1 << num_bits
        self.align_bits()
        if sign:
            return current // 2 if current % 2 else -(current // 2)
        return current - 1

    def read_float(self) -> float:
        float_type = self.read_byte()
        if float_type == 0:
            return 0.0
        if float_type == 1:
            return 1.0
        if float_type == 2:
            return -1.0
        if float_type == 3:
            return 0.5
        if float_type == 4:
            return float(self.read_int(sign=True))
        value = struct.unpack_from("<f", self.data, self.current_byte)[0]
        self.current_byte += 4
        return float(value)


class CCBIParser:
    def __init__(self, path: Path) -> None:
        self.path = path
        self.reader = BinaryReader(path.read_bytes())
        self.string_cache: list[str] = []
        self.js_controlled = False
        self.sequences: list[dict[str, Any]] = []
        self.auto_play_sequence_id: int | None = None

    def parse(self) -> RawNode:
        self._read_header()
        self._read_string_cache()
        self._read_sequences()
        return self._read_node()

    def _read_header(self) -> None:
        magic = self.reader.data[:4]
        if magic != MAGIC:
            raise ParseError(f"{self.path}: invalid magic {magic!r}")
        self.reader.current_byte = 4
        version = self.reader.read_int(sign=False)
        if version != CCB_VERSION:
            raise ParseError(f"{self.path}: unsupported version {version}")
        self.js_controlled = self.reader.read_bool()

    def _read_string_cache(self) -> None:
        count = self.reader.read_int(sign=False)
        self.string_cache = [self.reader.read_utf8() for _ in range(count)]

    def _read_cached_string(self) -> str:
        index = self.reader.read_int(sign=False)
        return self.string_cache[index]

    def _read_sequences(self) -> None:
        count = self.reader.read_int(sign=False)
        sequences: list[dict[str, Any]] = []
        for _ in range(count):
            sequences.append(
                {
                    "duration": self.reader.read_float(),
                    "name": self._read_cached_string(),
                    "sequenceId": self.reader.read_int(sign=False),
                    "chainedSequenceId": self.reader.read_int(sign=True),
                }
            )
        self.sequences = sequences
        self.auto_play_sequence_id = self.reader.read_int(sign=True)

    def _read_keyframe_value(self, type_id: int) -> Any:
        if type_id == 9:
            return self.reader.read_bool()
        if type_id == 12:
            return self.reader.read_byte()
        if type_id == 13:
            return [self.reader.read_byte(), self.reader.read_byte(), self.reader.read_byte()]
        if type_id == 5:
            return self.reader.read_float()
        if type_id in (0, 4):
            return [self.reader.read_float(), self.reader.read_float()]
        if type_id == 10:
            return [self._read_cached_string(), self._read_cached_string()]
        raise ParseError(f"{self.path}: unsupported keyframe type {type_id}")

    def _read_sequences_for_node(self) -> list[dict[str, Any]]:
        count = self.reader.read_int(sign=False)
        sequences = []
        for _ in range(count):
            sequence_id = self.reader.read_int(sign=False)
            prop_count = self.reader.read_int(sign=False)
            properties = []
            for _ in range(prop_count):
                prop_name = self._read_cached_string()
                prop_type = self.reader.read_int(sign=False)
                keyframe_count = self.reader.read_int(sign=False)
                keyframes = []
                for _ in range(keyframe_count):
                    time = self.reader.read_float()
                    easing_type = self.reader.read_int(sign=False)
                    easing_option = None
                    if easing_type in {2, 3, 4, 5, 6, 7}:
                        easing_option = self.reader.read_float()
                    keyframes.append(
                        {
                            "time": time,
                            "easingType": easing_type,
                            "easingOption": easing_option,
                            "value": self._read_keyframe_value(prop_type),
                        }
                    )
                properties.append(
                    {
                        "name": prop_name,
                        "typeId": prop_type,
                        "type": PROP_TYPE_NAMES.get(prop_type, f"unknown-{prop_type}"),
                        "keyframes": keyframes,
                    }
                )
            sequences.append({"sequenceId": sequence_id, "properties": properties})
        return sequences

    def _read_property_value(self, type_id: int) -> Any:
        if type_id == 0:
            return [self.reader.read_float(), self.reader.read_float(), self.reader.read_int(sign=False)]
        if type_id in (2, 3):
            return [self.reader.read_float(), self.reader.read_float()]
        if type_id == 1:
            return [self.reader.read_float(), self.reader.read_float(), self.reader.read_int(sign=False)]
        if type_id == 4:
            return [self.reader.read_float(), self.reader.read_float(), self.reader.read_int(sign=False)]
        if type_id in (5, 7):
            return self.reader.read_float()
        if type_id == 26:
            return [self.reader.read_float(), self.reader.read_int(sign=False)]
        if type_id in (6, 20):
            return self.reader.read_int(sign=True)
        if type_id == 8:
            return [self.reader.read_float(), self.reader.read_float()]
        if type_id == 9:
            return self.reader.read_bool()
        if type_id == 10:
            return [self._read_cached_string(), self._read_cached_string()]
        if type_id == 11:
            return self._read_cached_string()
        if type_id == 12:
            return self.reader.read_byte()
        if type_id == 13:
            return [self.reader.read_byte(), self.reader.read_byte(), self.reader.read_byte()]
        if type_id == 14:
            return [self.reader.read_float() for _ in range(8)]
        if type_id == 15:
            return [self.reader.read_bool(), self.reader.read_bool()]
        if type_id == 16:
            return [self.reader.read_int(sign=False), self.reader.read_int(sign=False)]
        if type_id == 17:
            return self._read_cached_string()
        if type_id in (18, 19, 24):
            return self._read_cached_string()
        if type_id == 21:
            return [self._read_cached_string(), self.reader.read_int(sign=False)]
        if type_id == 22:
            return [self._read_cached_string(), self._read_cached_string()]
        if type_id == 23:
            return self._read_cached_string()
        if type_id == 25:
            return [self._read_cached_string(), self.reader.read_int(sign=False), self.reader.read_int(sign=False)]
        raise ParseError(f"{self.path}: unsupported property type {type_id}")

    def _read_property(self) -> RawProperty:
        type_id = self.reader.read_int(sign=False)
        name = self._read_cached_string()
        platform = self.reader.read_byte()
        value = self._read_property_value(type_id)
        return RawProperty(name=name, type_id=type_id, platform=platform, value=value)

    def _read_node(self) -> RawNode:
        class_name = self._read_cached_string()
        js_controller_name = self._read_cached_string() if self.js_controlled else None
        member_assignment_type = self.reader.read_int(sign=False)
        member_assignment_name = self._read_cached_string() if member_assignment_type else None
        sequences = self._read_sequences_for_node()
        regular_prop_count = self.reader.read_int(sign=False)
        extra_prop_count = self.reader.read_int(sign=False)
        properties = [self._read_property() for _ in range(regular_prop_count + extra_prop_count)]
        child_count = self.reader.read_int(sign=False)
        children = [self._read_node() for _ in range(child_count)]
        return RawNode(
            class_name=class_name,
            member_assignment_type=member_assignment_type,
            member_assignment_name=member_assignment_name,
            js_controller_name=js_controller_name,
            properties=properties,
            children=children,
            sequences=sequences,
        )


class AssetCatalog:
    def __init__(self, repo_root: Path) -> None:
        self.repo_root = repo_root
        self.size_by_frame: dict[str, tuple[float, float]] = {}
        self.size_by_png: dict[Path, tuple[float, float]] = {}
        self._load_sprite_plists()

    def _load_sprite_plists(self) -> None:
        ingame_dir = self.repo_root / "legacy-reference" / "Resources" / "IMAGES" / "Ingame"
        for plist_path in sorted(ingame_dir.glob("*.plist")):
            with plist_path.open("rb") as handle:
                plist = plistlib.load(handle)
            frames = plist.get("frames", {})
            for name, info in frames.items():
                sprite_size = info.get("spriteSize")
                parsed = parse_pair_string(sprite_size) if isinstance(sprite_size, str) else None
                if parsed:
                    self.size_by_frame[name] = parsed

    def sprite_size(self, sheet: str | None, sprite_file: str | None) -> tuple[float, float] | None:
        if not sprite_file:
            return None
        sprite_name = Path(sprite_file).name
        if sprite_name in self.size_by_frame:
            return self.size_by_frame[sprite_name]
        direct_path = self.repo_root / "legacy-reference" / sprite_file
        if direct_path.exists():
            return self.png_size(direct_path)
        ingame_path = self.repo_root / "legacy-reference" / "Resources" / "IMAGES" / "Ingame" / sprite_name
        if ingame_path.exists():
            return self.png_size(ingame_path)
        return None

    def png_size(self, path: Path) -> tuple[float, float]:
        if path in self.size_by_png:
            return self.size_by_png[path]
        with path.open("rb") as handle:
            header = handle.read(24)
        if header[:8] != b"\x89PNG\r\n\x1a\n":
            raise ParseError(f"Unsupported image format for {path}")
        width, height = struct.unpack(">II", header[16:24])
        result = (float(width), float(height))
        self.size_by_png[path] = result
        return result


def parse_pair_string(value: str) -> tuple[float, float] | None:
    if not value:
        return None
    match = PAIR_PATTERN.search(value)
    if not match:
        return None
    return (float(match.group(1)), float(match.group(2)))


def ccb_percent(container: float, percent: float) -> float:
    """Match the engine's `(int)(container * percent / 100.0f)` cast.

    CCNode+CCBRelativePositioning.m truncates percent-resolved positions and
    sizes toward zero, so plain float maths drifts by up to a point.
    """
    return float(math.trunc(container * percent / 100.0))


def resolve_position(raw_value: list[float] | None, parent_size: tuple[float, float]) -> tuple[float, float]:
    if not raw_value:
        return (0.0, 0.0)
    x, y, position_type = raw_value
    width, height = parent_size
    if position_type == 0:
        return (x, y)
    if position_type == 1:
        return (x, height - y)
    if position_type == 2:
        return (width - x, height - y)
    if position_type == 3:
        return (width - x, y)
    if position_type == 4:
        return (ccb_percent(width, x), ccb_percent(height, y))
    if position_type == 5:
        return (x, y)
    raise ParseError(f"Unsupported position type {position_type}")


def resolve_size(raw_value: list[float] | None, parent_size: tuple[float, float]) -> tuple[float, float]:
    if not raw_value:
        return (0.0, 0.0)
    width, height, size_type = raw_value
    parent_width, parent_height = parent_size
    if size_type == 0:
        return (width, height)
    if size_type == 1:
        return (ccb_percent(parent_width, width), ccb_percent(parent_height, height))
    if size_type == 2:
        return (parent_width - width, parent_height - height)
    if size_type == 3:
        return (ccb_percent(parent_width, width), height)
    if size_type == 4:
        return (width, ccb_percent(parent_height, height))
    if size_type == 5:
        return (width, height)
    raise ParseError(f"Unsupported size type {size_type}")


def resolve_scale(raw_value: list[float] | None) -> tuple[float, float]:
    if not raw_value:
        return (1.0, 1.0)
    return (float(raw_value[0]), float(raw_value[1]))


def cocos_local_transform(
    position_value: tuple[float, float],
    rotation: float,
    scale_value: tuple[float, float],
    anchor_point: tuple[float, float],
    content_size: tuple[float, float],
    ignore_anchor_for_position: bool,
) -> AffineTransform:
    position_x, position_y = position_value
    scale_x, scale_y = scale_value
    anchor_x = content_size[0] * anchor_point[0]
    anchor_y = content_size[1] * anchor_point[1]

    adjusted_x = position_x + (anchor_x if ignore_anchor_for_position else 0.0)
    adjusted_y = position_y + (anchor_y if ignore_anchor_for_position else 0.0)

    radians = math.radians(rotation)
    cos_value = math.cos(radians)
    sin_value = math.sin(radians)

    a = cos_value * scale_x
    b = sin_value * scale_x
    c = -sin_value * scale_y
    d = cos_value * scale_y
    tx = adjusted_x
    ty = adjusted_y

    if anchor_x or anchor_y:
        tx += a * -anchor_x + c * -anchor_y
        ty += b * -anchor_x + d * -anchor_y

    return AffineTransform(a=a, b=b, c=c, d=d, tx=tx, ty=ty)


def apply_scale_to_size(content_size: tuple[float, float], transform: AffineTransform) -> tuple[float, float]:
    scale_x = math.sqrt(transform.a * transform.a + transform.b * transform.b)
    scale_y = math.sqrt(transform.c * transform.c + transform.d * transform.d)
    return (content_size[0] * scale_x, content_size[1] * scale_y)


def normalize_sprite_frame(value: Any) -> dict[str, str | None] | None:
    if not isinstance(value, list) or len(value) != 2:
        return None
    sprite_sheet, sprite_file = value
    return {
        "sheet": Path(sprite_sheet).name if sprite_sheet else None,
        "file": Path(sprite_file).name if sprite_file else None,
        "sourceSheet": sprite_sheet or None,
        "sourceFile": sprite_file or None,
    }


def normalize_color(value: Any) -> dict[str, int] | None:
    if not isinstance(value, list) or len(value) != 3:
        return None
    return {"r": int(value[0]), "g": int(value[1]), "b": int(value[2])}


def infer_spawn_point(viewport: tuple[float, float]) -> dict[str, float]:
    width, height = viewport
    spawn_y = 65.0 if height >= 568 else 60.0
    return point(width / 2.0, spawn_y)


def derive_time_limit(top_boundary_y: float | None) -> int:
    if top_boundary_y is None:
        return 30
    if top_boundary_y > 5000:
        return 90
    if top_boundary_y > 2500:
        return 60
    return 30


def flatten_nodes(node: ResolvedNode) -> Iterable[ResolvedNode]:
    yield node
    for child in node.children:
        yield from flatten_nodes(child)


def raw_tree_to_json(node: RawNode) -> dict[str, Any]:
    return {
        "className": node.class_name,
        "memberAssignment": {
            "type": node.member_assignment_type,
            "name": node.member_assignment_name,
        }
        if node.member_assignment_type
        else None,
        "jsControllerName": node.js_controller_name,
        "properties": [
            {
                "name": prop.name,
                "type": prop.type_name,
                "typeId": prop.type_id,
                "platform": prop.platform,
                "value": prop.value,
            }
            for prop in node.properties
        ],
        "children": [raw_tree_to_json(child) for child in node.children],
    }


def ccb_plist_to_raw_tree(node: dict[str, Any]) -> RawNode:
    properties = []
    for entry in node.get("properties", []):
        raw_value = entry.get("value")
        if entry.get("type") == "ScaleLock" and isinstance(raw_value, list) and len(raw_value) == 4:
            raw_value = [raw_value[0], raw_value[1], raw_value[3]]
        properties.append(
            RawProperty(
                name=entry["name"],
                type_id=next((k for k, v in PROP_TYPE_NAMES.items() if v == entry["type"]), -1),
                platform=0,
                value=raw_value,
            )
        )
    return RawNode(
        class_name=node.get("customClass") or node.get("baseClass"),
        properties=properties,
        children=[ccb_plist_to_raw_tree(child) for child in node.get("children", [])],
    )


def comparable_value(name: str, value: Any) -> Any:
    if name == "displayFrame":
        normalized = normalize_sprite_frame(value)
        return (normalized or {}).get("file")
    if name == "contentSize" and isinstance(value, list) and len(value) == 3:
        return [round_number(value[0]), round_number(value[1]), int(value[2])]
    if name in {"position", "scale"} and isinstance(value, list) and len(value) == 3:
        return [round_number(value[0]), round_number(value[1]), int(value[2])]
    if name == "anchorPoint" and isinstance(value, list):
        return [round_number(v) for v in value]
    if isinstance(value, float):
        return round_number(value)
    if isinstance(value, list):
        return [comparable_value(name, item) for item in value]
    return value


def compare_raw_trees(parsed: RawNode, ccb_tree: RawNode) -> dict[str, Any]:
    parsed_nodes = list(_flatten_raw(parsed))
    ccb_nodes = list(_flatten_raw(ccb_tree))
    mismatches: list[str] = []

    if len(parsed_nodes) != len(ccb_nodes):
        mismatches.append(f"node count mismatch: ccbi={len(parsed_nodes)} ccb={len(ccb_nodes)}")

    for index, (lhs, rhs) in enumerate(zip(parsed_nodes, ccb_nodes)):
        if lhs.class_name != rhs.class_name:
            mismatches.append(f"node {index} class mismatch: ccbi={lhs.class_name} ccb={rhs.class_name}")
            continue
        lhs_props = {prop.name: comparable_value(prop.name, prop.value) for prop in lhs.properties}
        rhs_props = {prop.name: comparable_value(prop.name, prop.value) for prop in rhs.properties}
        for key in sorted(set(lhs_props) | set(rhs_props)):
            if lhs_props.get(key) != rhs_props.get(key):
                mismatches.append(
                    f"node {index} {lhs.class_name} property {key} mismatch: ccbi={lhs_props.get(key)!r} ccb={rhs_props.get(key)!r}"
                )
        if len(mismatches) >= 20:
            break

    return {
        "status": "pass" if not mismatches else "mismatch",
        "nodeCountCcbi": len(parsed_nodes),
        "nodeCountCcb": len(ccb_nodes),
        "mismatches": mismatches,
    }


def _flatten_raw(node: RawNode) -> Iterable[RawNode]:
    yield node
    for child in node.children:
        yield from _flatten_raw(child)


def collect_timeline_overrides(root: RawNode) -> list[dict[str, Any]]:
    """Report autoplay keyframes at t=0 that disagree with the static property.

    CCBReader runs the autoplay sequence with `tweenDuration:0` immediately
    after loading, so a t=0 keyframe wins over the static value. In the shipped
    levels every such keyframe is a no-op, but this guards against silently
    dropping a real override if new level data ever appears.
    """
    overrides: list[dict[str, Any]] = []
    for index, node in enumerate(_flatten_raw(root)):
        if not node.sequences:
            continue
        static_values = node.property_map()
        for sequence in node.sequences:
            for prop in sequence["properties"]:
                first = next((kf for kf in prop["keyframes"] if kf["time"] == 0.0), None)
                if first is None:
                    continue
                static_prop = static_values.get(prop["name"])
                static_value = static_prop.value if static_prop else None
                if not _keyframe_matches_static(prop["name"], first["value"], static_value):
                    overrides.append(
                        {
                            "nodeIndex": index,
                            "className": node.class_name,
                            "property": prop["name"],
                            "staticValue": static_value,
                            "keyframeValue": first["value"],
                        }
                    )
    return overrides


def _keyframe_matches_static(name: str, keyframe_value: Any, static_value: Any) -> bool:
    if static_value is None:
        return False
    # Position/size/scale keyframes carry only the two components, while the
    # static property also carries its relative-coordinate type.
    if (
        isinstance(keyframe_value, list)
        and isinstance(static_value, list)
        and len(keyframe_value) == 2
        and len(static_value) == 3
    ):
        static_value = static_value[:2]
    if isinstance(keyframe_value, list) and isinstance(static_value, list):
        return [comparable_value(name, item) for item in keyframe_value] == [
            comparable_value(name, item) for item in static_value
        ]
    return comparable_value(name, keyframe_value) == comparable_value(name, static_value)


class LevelConverter:
    def __init__(self, repo_root: Path, viewport: tuple[float, float]) -> None:
        self.repo_root = repo_root
        self.viewport = viewport
        self.assets = AssetCatalog(repo_root)

    def convert(self, ccbi_path: Path, include_node_tree: bool = False, validate_with_ccb: bool = False) -> dict[str, Any]:
        parser = CCBIParser(ccbi_path)
        raw_root = parser.parse()
        resolved_root = self._resolve_node(raw_root, parent_size=self.viewport, parent_transform=AffineTransform(), parent_rotation=0.0, path="root")
        level_json = self._extract_level(ccbi_path, parser, raw_root, resolved_root)

        if include_node_tree:
            level_json["nodeTree"] = raw_tree_to_json(raw_root)

        if validate_with_ccb:
            ccb_path = self.repo_root / "legacy-reference" / "Resources" / "DATA" / "LEVEL BUILDER" / ccbi_path.with_suffix(".ccb").name
            if ccb_path.exists():
                with ccb_path.open("rb") as handle:
                    ccb_doc = plistlib.load(handle)
                level_json["validation"] = compare_raw_trees(raw_root, ccb_plist_to_raw_tree(ccb_doc["nodeGraph"]))
            else:
                level_json["validation"] = {"status": "missing-ccb", "path": str(ccb_path)}

        return level_json

    def _resolve_node(
        self,
        node: RawNode,
        parent_size: tuple[float, float],
        parent_transform: AffineTransform,
        parent_rotation: float,
        path: str,
    ) -> ResolvedNode:
        props = node.property_map()
        property_values = {name: prop.value for name, prop in props.items()}
        sprite_frame = normalize_sprite_frame(property_values.get("displayFrame"))
        content_size = resolve_size(property_values.get("contentSize"), parent_size) if "contentSize" in property_values else None
        if content_size is None:
            inferred = self.assets.sprite_size((sprite_frame or {}).get("sourceSheet"), (sprite_frame or {}).get("sourceFile"))
            content_size = inferred or (0.0, 0.0)

        anchor_point_raw = property_values.get("anchorPoint", [0.0, 0.0])
        anchor_point = (float(anchor_point_raw[0]), float(anchor_point_raw[1]))
        scale_value = resolve_scale(property_values.get("scale"))
        rotation = float(property_values.get("rotation", 0.0))
        ignore_anchor = bool(property_values.get("ignoreAnchorPointForPosition", False))
        position_value = resolve_position(property_values.get("position"), parent_size)

        local_transform = cocos_local_transform(
            position_value=position_value,
            rotation=rotation,
            scale_value=scale_value,
            anchor_point=anchor_point,
            content_size=content_size,
            ignore_anchor_for_position=ignore_anchor,
        )
        world_transform = parent_transform.concat(local_transform)

        adjusted_position = (
            position_value[0] + (content_size[0] * anchor_point[0] if ignore_anchor else 0.0),
            position_value[1] + (content_size[1] * anchor_point[1] if ignore_anchor else 0.0),
        )
        world_position = parent_transform.apply(*adjusted_position)
        world_size = apply_scale_to_size(content_size, world_transform)

        children = [
            self._resolve_node(
                child,
                parent_size=content_size,
                parent_transform=world_transform,
                parent_rotation=parent_rotation + rotation,
                path=f"{path}/{index}:{child.class_name}",
            )
            for index, child in enumerate(node.children)
        ]

        resolved_values = dict(property_values)
        resolved_values["displayFrame"] = sprite_frame
        resolved_values["anchorPoint"] = point(*anchor_point)
        resolved_values["position"] = point(*position_value)
        resolved_values["scale"] = point(*scale_value)
        resolved_values["rotation"] = round_number(rotation)
        resolved_values["contentSize"] = size(*content_size)
        resolved_values["color"] = normalize_color(property_values.get("color"))

        return ResolvedNode(
            raw=node,
            path=path,
            class_name=node.class_name,
            properties=resolved_values,
            position=position_value,
            world_position=world_position,
            content_size=content_size,
            world_size=world_size,
            rotation=rotation,
            world_rotation=parent_rotation + rotation,
            scale=scale_value,
            world_transform=world_transform,
            children=children,
        )

    def _extract_level(self, ccbi_path: Path, parser: CCBIParser, raw_root: RawNode, resolved_root: ResolvedNode) -> dict[str, Any]:
        match = LEVEL_PATTERN.search(ccbi_path.name)
        if not match:
            raise ParseError(f"Could not parse world/level from {ccbi_path.name}")
        world = int(match.group(1))
        level = int(match.group(2))
        theme = WORLD_THEME_MAP.get(world, {"theme": f"world-{world}", "backgroundImage": f"bg-world-{world}.png"})

        platforms: list[dict[str, Any]] = []
        collectables: list[dict[str, Any]] = []
        enemies: list[dict[str, Any]] = []
        triggers: list[dict[str, Any]] = []
        projectile_spawners: list[dict[str, Any]] = []
        tips: list[dict[str, Any]] = []
        unknown_nodes: list[dict[str, Any]] = []
        counters: Counter[str] = Counter()

        for node in flatten_nodes(resolved_root):
            if node is resolved_root:
                continue
            entry = self._node_common(node)
            if node.class_name == "Platform":
                counters["platform"] += 1
                tag = node.properties.get("tag")
                mapping = PLATFORM_TAG_MAP.get(tag, {"kind": "unknown", "behavior": {"mode": f"legacyTag-{tag}"}})
                platforms.append(
                    {
                        "id": f"platform-{counters['platform']:03d}",
                        **entry,
                        "legacyTag": tag,
                        "kind": mapping["kind"],
                        "behavior": mapping["behavior"],
                    }
                )
            elif node.class_name in COLLECTABLE_CLASS_MAP:
                counters["collectable"] += 1
                collectable_info = COLLECTABLE_CLASS_MAP[node.class_name]
                collectables.append(
                    {
                        "id": f"collectable-{counters['collectable']:03d}",
                        **entry,
                        "kind": collectable_info["kind"],
                        "value": collectable_info["value"],
                    }
                )
            elif node.class_name == "Enemy":
                counters["enemy"] += 1
                tag = node.properties.get("tag")
                mapping = ENEMY_TAG_MAP.get(tag, {"kind": "unknown", "behavior": {"mode": f"legacyTag-{tag}"}})
                enemy_id = f"enemy-{counters['enemy']:03d}"
                enemy_entry = {
                    "id": enemy_id,
                    **entry,
                    "legacyTag": tag,
                    "kind": mapping["kind"],
                    "behavior": mapping["behavior"],
                }
                enemies.append(enemy_entry)
                spawner = self._projectile_spawner_from_enemy(enemy_entry, node)
                if spawner:
                    projectile_spawners.append(spawner)
            elif node.class_name == "Trigger":
                counters["trigger"] += 1
                trigger_kind = "levelTopBoundary" if node.properties.get("tag") == 100 else "trigger"
                triggers.append(
                    {
                        "id": f"trigger-{counters['trigger']:03d}",
                        **entry,
                        "legacyTag": node.properties.get("tag"),
                        "kind": trigger_kind,
                    }
                )
            elif node.class_name == "Tip":
                counters["tip"] += 1
                tips.append({"id": f"tip-{counters['tip']:03d}", **entry})
            elif node.class_name not in {"CCNode", "GameLayer", "CCLayer", "CCSprite"}:
                unknown_nodes.append({"className": node.class_name, "path": node.path})

        goal_platform = next((platform for platform in platforms if platform.get("legacyTag") == 100), None)
        top_trigger = next((trigger for trigger in triggers if trigger.get("legacyTag") == 100), None)
        top_boundary_y = (top_trigger or {}).get("position", {}).get("y") if top_trigger else None

        parked_counts = {
            name: sum(1 for item in collection if not item.get("playable", True))
            for name, collection in (
                ("platforms", platforms),
                ("collectables", collectables),
                ("enemies", enemies),
                ("triggers", triggers),
                ("tips", tips),
            )
        }
        playable_collectables = [item for item in collectables if item.get("playable", True)]
        collectable_kinds = Counter(item["kind"] for item in playable_collectables)

        return {
            "schemaVersion": "1.1.0",
            "source": {
                "ccbi": str(ccbi_path.relative_to(self.repo_root)),
                "world": world,
                "level": level,
            },
            "coordinateSpace": {
                "kind": "points",
                "logicalViewport": size(*self.viewport),
                "notes": "Coordinates are resolved from CocosBuilder relative values into point-space using the chosen logical viewport.",
            },
            "metadata": {
                "theme": theme["theme"],
                "backgroundImage": theme["backgroundImage"],
                "timeLimitSeconds": derive_time_limit(top_boundary_y),
                "topBoundaryY": round_number(top_boundary_y),
                "nodeCount": sum(1 for _ in flatten_nodes(resolved_root)),
                "timelineNames": [sequence["name"] for sequence in parser.sequences],
                "autoPlaySequenceId": parser.auto_play_sequence_id,
                "playableCollectables": {
                    "small": collectable_kinds.get("small", 0),
                    "big": collectable_kinds.get("big", 0),
                    "halo": collectable_kinds.get("halo", 0),
                },
            },
            "playerSpawn": infer_spawn_point(self.viewport),
            "goal": {
                "requiresBigCollectables": 1,
                "platformId": goal_platform["id"] if goal_platform else None,
                "position": goal_platform["position"] if goal_platform else None,
            },
            "platforms": platforms,
            "collectables": collectables,
            "enemies": enemies,
            "projectileSpawners": projectile_spawners,
            "triggers": triggers,
            "tips": tips,
            "diagnostics": {
                "unknownNodes": unknown_nodes,
                "rawRootClass": raw_root.class_name,
                "parkedObjects": parked_counts,
                "parkedObjectTotal": sum(parked_counts.values()),
                "timelineOverrides": collect_timeline_overrides(raw_root),
            },
        }

    def _node_common(self, node: ResolvedNode) -> dict[str, Any]:
        sprite_frame = node.properties.get("displayFrame")
        return {
            "position": point(*node.world_position),
            "size": size(*node.world_size),
            "rotationDegrees": round_number(node.world_rotation),
            "spriteFrame": sprite_frame["file"] if sprite_frame else None,
            "spriteSheet": sprite_frame["sheet"] if sprite_frame else None,
            "tint": node.properties.get("color"),
            "opacity": node.properties.get("opacity", 255),
            "visible": node.properties.get("visible", True),
            "playable": self._is_playable(node),
        }

    def _is_playable(self, node: ResolvedNode) -> bool:
        """Reject CocosBuilder "parking stash" objects the player can never reach.

        The player is driven straight from the touch x, so it is confined to
        [0, viewportWidth]. Worlds 3 and 4 were authored from a template that
        keeps a palette of spare objects parked either side of the screen; the
        original game loads them but they are unreachable and get culled.
        """
        half_width = node.world_size[0] / 2.0
        left = node.world_position[0] - half_width
        right = node.world_position[0] + half_width
        return right > 0.0 and left < self.viewport[0]

    def _projectile_spawner_from_enemy(self, enemy_entry: dict[str, Any], node: ResolvedNode) -> dict[str, Any] | None:
        if enemy_entry.get("kind") != "rocketLauncher":
            return None
        base_y_offset = 355 if self.viewport[1] >= 568 else 300
        projectile_y = node.world_position[1] - (node.world_size[1] / 2.0) + base_y_offset
        return {
            "id": f"spawner-{enemy_entry['id']}",
            "kind": "rocket",
            "sourceEnemyId": enemy_entry["id"],
            "launchPosition": point(27.0, projectile_y),
            "projectileSpeed": 473 if self.viewport[1] >= 568 else 400,
            "targeting": "cross-screen toward player lane",
        }


def summarize_level(level_data: dict[str, Any]) -> dict[str, Any]:
    x_values = []
    y_values = []
    for collection_name in ["platforms", "collectables", "enemies", "triggers"]:
        for item in level_data.get(collection_name, []):
            position_value = item.get("position", {})
            if "x" in position_value:
                x_values.append(position_value["x"])
            if "y" in position_value:
                y_values.append(position_value["y"])
    return {
        "level": f"world-{level_data['source']['world']}-level-{level_data['source']['level']}",
        "platforms": len(level_data.get("platforms", [])),
        "collectables": len(level_data.get("collectables", [])),
        "enemies": len(level_data.get("enemies", [])),
        "triggers": len(level_data.get("triggers", [])),
        "spawners": len(level_data.get("projectileSpawners", [])),
        "parked": level_data.get("diagnostics", {}).get("parkedObjectTotal", 0),
        "topBoundaryY": level_data.get("metadata", {}).get("topBoundaryY"),
        "timeLimitSeconds": level_data.get("metadata", {}).get("timeLimitSeconds"),
        "xRange": [min(x_values), max(x_values)] if x_values else None,
        "yRange": [min(y_values), max(y_values)] if y_values else None,
        "validation": (level_data.get("validation") or {}).get("status"),
    }


def expand_inputs(repo_root: Path, inputs: list[str]) -> list[Path]:
    expanded: list[Path] = []
    seen: set[Path] = set()
    for value in inputs:
        matches = [Path(match) for match in globlib.glob(value)]
        if not matches:
            candidate = (repo_root / value).resolve() if not Path(value).is_absolute() else Path(value)
            matches = [candidate]
        for match in matches:
            resolved = match.resolve()
            if resolved.suffix != ".ccbi":
                continue
            if resolved not in seen:
                seen.add(resolved)
                expanded.append(resolved)
    return sorted(expanded)


def parse_viewport(value: str) -> tuple[float, float]:
    try:
        width_raw, height_raw = value.lower().split("x", 1)
        return (float(width_raw), float(height_raw))
    except ValueError as exc:
        raise argparse.ArgumentTypeError("viewport must look like 320x480") from exc


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inputs", nargs="+", help=".ccbi file(s) or glob(s) to convert")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2], help="repository root")
    parser.add_argument("--output-dir", type=Path, help="directory to write JSON files into")
    parser.add_argument("--viewport", type=parse_viewport, default=(320.0, 480.0), help="logical viewport used to resolve relative coordinates (default: 320x480)")
    parser.add_argument("--include-node-tree", action="store_true", help="embed the parsed raw node tree for debugging")
    parser.add_argument("--validate-with-ccb", action="store_true", help="compare parsed .ccbi data with the matching human-readable .ccb file when present")
    parser.add_argument("--summary-only", action="store_true", help="print summaries without writing JSON files")
    parser.add_argument("--summary-file", type=Path, help="optional path for a JSON validation summary")
    args = parser.parse_args(argv)

    repo_root = args.repo_root.resolve()
    inputs = expand_inputs(repo_root, args.inputs)
    if not inputs:
        parser.error("no .ccbi inputs resolved")

    converter = LevelConverter(repo_root=repo_root, viewport=args.viewport)
    summaries = []
    for ccbi_path in inputs:
        level_data = converter.convert(
            ccbi_path=ccbi_path,
            include_node_tree=args.include_node_tree,
            validate_with_ccb=args.validate_with_ccb,
        )
        summary = summarize_level(level_data)
        summaries.append(summary)
        print(
            f"{summary['level']}: "
            f"platforms={summary['platforms']} collectables={summary['collectables']} "
            f"enemies={summary['enemies']} triggers={summary['triggers']} spawners={summary['spawners']} "
            f"parked={summary['parked']} "
            f"top={summary['topBoundaryY']} time={summary['timeLimitSeconds']} validation={summary['validation']}"
        )
        if args.output_dir and not args.summary_only:
            output_path = args.output_dir / ccbi_path.with_suffix(".json").name
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(json.dumps(level_data, indent=2) + "\n", encoding="utf-8")

    if args.summary_file:
        args.summary_file.parent.mkdir(parents=True, exist_ok=True)
        args.summary_file.write_text(json.dumps(summaries, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

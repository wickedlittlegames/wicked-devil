# CCBI level converter

Standalone Python 3 CLI for migrating Wicked Little Devil level data from compiled CocosBuilder `.ccbi` files into Swift/SpriteKit-friendly JSON.

## What it does

- Parses the bundled CocosBuilder binary format directly from `Wicked Little Devil/libs/CCBReader/CCBReader.m` semantics:
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
  'Wicked Little Devil/Resources/DATA/LEVELS/world-1-level-*.ccbi' \
  --output-dir tools/ccbi-converter/output \
  --validate-with-ccb
```

Representative validation run:

```bash
python3 tools/ccbi-converter/convert_ccbi.py \
  'Wicked Little Devil/Resources/DATA/LEVELS/world-1-level-*.ccbi' \
  'Wicked Little Devil/Resources/DATA/LEVELS/world-3-level-17.ccbi' \
  'Wicked Little Devil/Resources/DATA/LEVELS/world-20-level-1.ccbi' \
  --output-dir tools/ccbi-converter/samples \
  --summary-file tools/ccbi-converter/samples/validation-summary.json \
  --validate-with-ccb
```

## Important assumptions

- Output coordinates are **resolved point coordinates**, not raw CCB percentages.
- Default logical viewport is `320x480`, matching the non-iPhone-5 branch in game code.
- Use `--viewport 320x568` if you want the taller-device resolution instead.
- The converter does **not** modify anything under `Wicked Little Devil/`.

## JSON schema

Top-level shape:

- `schemaVersion`
- `source` — source file + world/level numbers
- `coordinateSpace` — resolved viewport metadata
- `metadata` — theme/background/time-limit/level height
- `playerSpawn` — derived from `PlayerLayer.m`
- `goal` — finish platform summary
- `platforms[]`
- `collectables[]`
- `enemies[]`
- `projectileSpawners[]`
- `triggers[]`
- `tips[]`
- `diagnostics` — unknown nodes / parser hints
- optional `nodeTree` — raw parsed CCBI node graph

### Example

```json
{
  "schemaVersion": "1.0.0",
  "source": {
    "ccbi": "Wicked Little Devil/Resources/DATA/LEVELS/world-1-level-20.ccbi",
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

The repo includes matching `.ccb` sources in `Wicked Little Devil/Resources/DATA/LEVEL BUILDER/`.

With `--validate-with-ccb`, the converter compares:

- node count
- preorder node classes
- gameplay-relevant properties (`position`, `contentSize`, `scale`, `tag`, `displayFrame`, `opacity`, `color`, etc.)

This is the quickest way to confirm that the binary parse still matches the authoring source before converting the full catalog.

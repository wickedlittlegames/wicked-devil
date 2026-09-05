# Level data migration report

Migration of the original CocosBuilder level binaries to JSON for the Swift +
SpriteKit rewrite.

- **Source:** `legacy-reference/Resources/DATA/LEVELS/*.ccbi` (read-only)
- **Output:** `WickedLittleDevilSwift/Resources/Levels/*.json` (schema `1.1.0`, 6.5 MB)
- **Result:** 91 / 91 levels converted, cross-checked and verified. No failures, no warnings.

## 1. Inventory

The brief anticipated something like 240 levels. The shipped catalogue is much
smaller — **91 levels**, not 240:

| World | Levels | Theme | Background | Notes |
|-------|--------|-------|------------|-------|
| 1  | 20 | `hell`        | `bg-world-1.png`  | |
| 2  | 20 | `underground` | `bg-world-2.png`  | |
| 3  | 20 | `ocean`       | `bg-world-3.png`  | |
| 4  | 20 | `land`        | `bg-world-4.png`  | |
| 11 | 1  | `bonus`       | `bg-world-1.png`  | Single bonus level |
| 20 | 10 | `detective`   | `bg-world-20.png` | "Detective" side campaign |
| **Total** | **91** | | | |

This matches the game's own constants. `GameConstants.h` declares
`LEVELS_PER_WORLD 20` and `WORLDS_PER_GAME 12`, but also
`CURRENT_WORLDS_PER_GAME 4` — worlds 5–12 were scoped but never authored. 240
was the design ceiling; 4 × 20 is what actually shipped.

The two extra worlds are both real, reachable content:

- **World 11** is a one-off bonus level launched from `StartScene.m:171`
  (`sceneWithWorld:11 andLevel:1`) and treated as a bonus in `GameOverScene.m:44`.
  `BGLayer.m:23-24` special-cases it to draw the world-1 background; the
  converter reproduces this exactly.
- **World 20** is the Detective campaign behind `DetectiveLevelSelectScene.m`,
  with its own background art and only 10 levels.

Each `.ccbi` has a matching human-readable `.ccb` plist in
`legacy-reference/Resources/DATA/LEVEL BUILDER/` (91 of those too), which is
what makes the independent cross-check below possible.

## 2. Results

### Conversion

| Check | Result |
|-------|--------|
| Levels converted without exception | 91 / 91 |
| Output is valid strict JSON (no `NaN`/`Infinity`) | 91 / 91 |
| Cross-checked against `.ccb` plist source | 91 / 91 `pass` |
| `verify_levels.py` | 91 pass, 0 warn, 0 fail |
| Unknown/unhandled node types | 0 |
| Timeline keyframes overriding static properties | 0 |

Evidence: `ccb-crosscheck.json` (per-level decode cross-check) and
`verification-report.json` (per-level verification stats).

### Per-world content

Counts are playable objects; the parked palette described in §4 is excluded.

| World | Levels | Platforms | Collectables (S/B/H) | Enemies | Spawners |
|-------|--------|-----------|----------------------|---------|----------|
| 1  | 20 | 392 | 1800 / 60 / 20 | 5   | 0  |
| 2  | 20 | 430 | 1615 / 60 / 20 | 154 | 0  |
| 3  | 20 | 393 | 1824 / 60 / 20 | 234 | 0  |
| 4  | 20 | 556 | 1920 / 60 / 20 | 141 | 95 |
| 11 | 1  | 24  | 390 / 3 / 0    | 0   | 0  |
| 20 | 10 | 371 | 2074 / 30 / 0  | 50  | 20 |

The collectable columns are a strong signal that the decode is correct: every
level in worlds 1–4 has **exactly 3 BigCollectables and exactly 1 halo**
(60 = 3 × 20, 20 = 1 × 20), and world 20 has exactly 3 big and no halo per
level. That regularity falls out of the data rather than being asserted by the
converter, so a systematic misparse would have broken it.

Object kinds resolved across the catalogue:

- **Platforms:** normal 1003, breakable 406, moving 353, boost 266,
  toggleTarget 242, switch 116, goal 91, movingBreakable 30
- **Enemies:** mine 450, rocketLauncher 115, bubble 67, bat 8

`goal: 91` is exactly one finish platform per level, as expected.

### Level shape

- Level heights vary the way hand-designed levels do rather than climbing
  steadily: world 1 runs 480 → 3715 pt overall but dips back to 527 pt at
  level 9. Shortest are `world-1-level-1` and `world-1-level-2` at 480 pt (one
  screen); tallest are `world-11-level-1` and `world-20-level-10` at 4826 pt.
- Time limits: 78 levels at 30 s, 13 at 60 s. No level exceeds the 5000 pt
  threshold that would earn 90 s, so that branch of the legacy rule is
  unreachable in shipped content — correct, not a bug.
- Every level's `timeLimitSeconds` was independently re-derived from
  `GameScene.m:174-180` and matched.

## 3. Converter bug found and fixed: percent truncation

**This was the one genuine correctness bug**, and it affected essentially every
object in the game.

`CCNode+CCBRelativePositioning.m` resolves percent-relative positions as:

```objc
absPt.x = (int)(containerSize.width * pt.x / 100.0f);
```

The `(int)` cast truncates **toward zero**, and the same cast is applied to
percent sizes. The converter was doing plain floating-point maths, so nearly
every coordinate carried up to a point of error — for example
`world-1-level-20/platform-002` sat at `y = 102.867` instead of the engine's
`y = 102`.

A sub-point error sounds harmless, but this is a vertical platformer whose
landing detection compares the player's feet against exact platform edges;
consistent drift on every platform in the game is exactly the kind of thing
that makes a jump feel subtly wrong and is near-impossible to debug later.

Fixed by adding a `ccb_percent()` helper using `math.trunc` (**not** `math.floor`
— they disagree for the negative percentages used by the parked objects in
worlds 3 and 4) and routing all percent position and size resolution through it.

Impact after the fix, measured against the previously committed samples:
263 objects changed in `world-1-level-20`, 87 in `world-3-level-17`, 149 in
`world-4-level-7`, 260 in `world-20-level-1`.

## 4. Anomalies investigated

### 4.1 Objects at impossible coordinates — *not a converter bug*

Initial verification failed en masse across worlds 3 and 4, with objects at
`x ≈ 567…604`, `x ≈ -180…-265` and `y` as low as `-88` — well outside the
320 × 480 play area.

These are genuine source data, not a decode error:

- The `.ccb` plist cross-check passes for all of these levels, so the binary was
  decoded faithfully.
- The raw node properties really do contain percentages above 100 and below 0
  (e.g. `[177.8125, 4.347, 4]`).
- None of these nodes carry timeline keyframes, so nothing repositions them at
  runtime.
- Their tag sequence (`None, 33, 3, 1, 6, 2, …`) is **one of each platform
  variant** — the signature of a designer's palette.

Diagnosis: worlds 3 and 4 were authored from a template that keeps a stash of
spare objects parked just outside the play area, and the designer never cleared
it. The original game loads them but the player can never reach them —
`GameScene.m:250-259` drives the player's `x` directly from the touch position,
confining them to `0...320`, and `GameLayer`'s update culls objects that drop
below the camera.

| World | Levels affected | Parked objects |
|-------|-----------------|----------------|
| 1  | 4 / 20  | 5   |
| 2  | 5 / 20  | 8   |
| 3  | 20 / 20 | 466 |
| 4  | 20 / 20 | 539 |
| 11 | 0 / 1   | 0   |
| 20 | 3 / 10  | 56  |
| **Total** | **52 / 91** | **1074** |

The concentration in worlds 3 and 4 (100% of levels, ~94% of the objects)
confirms the template theory — those two worlds were built later from a
different starting file.

Handling: objects are **kept** for fidelity but flagged `playable: false`, using
a horizontal bounding-box test against the viewport. The separation is clean
rather than a judgement call — every below-floor object is also horizontally
off-screen, and the lowest horizontally-on-screen object across all 91 levels
sits at `y = 27.148`, so there is no ambiguous middle ground. Consumers should
simulate only `playable` objects.

### 4.2 `world-1-level-11` has two triggers

Every other level has exactly one trigger; this level has two, both tagged 100.
Harmless: `GameScene.m:174` reads `[layer_game.triggers objectAtIndex:0]`, so
only the first is ever used, and the converter selects the same one. Recorded
here only so it isn't mistaken for corruption later.

### 4.3 Autoplay timeline keyframes

`CCBReader.m:1109-1112` runs the autoplay sequence with `tweenDuration:0`
immediately after load, so a keyframe at `t=0` silently overrides the static
property value the converter reads. 38 nodes across 7 levels carry sequences
(`visible` × 33, `displayFrame` × 4, `scale` × 1).

Every one was checked: **all t=0 keyframes are identical to their static
values**, so all are no-ops and no coordinates are affected. The converter now
emits `diagnostics.timelineOverrides` as a permanent regression guard — it is
empty on all 91 levels, and a non-empty entry would mean that node's data is
wrong.

### 4.4 Non-issues confirmed

- **Node collection semantics.** `GameLayer.createWorldWithObjects:` collects
  most types from direct children but `Collectable` only from grandchildren. The
  actual depth distribution matches this exactly (all `Collectable` nodes are at
  depth 2 inside `CCNode` groups; everything else is at depth 1), so the
  converter's full-tree flatten collects precisely the same set — no over- or
  under-collection.
- **Sprite sizing.** All 56 sprite frames have `textureRotated: false` and
  `spriteSize == spriteSourceSize`, so deriving content sizes from the frame
  metadata is safe.
- **`tips[]` is empty on every level.** The `Tip` class exists in the original
  source but no shipped level uses it. Expected, not a parsing gap.

## 5. Changes made

`tools/ccbi-converter/convert_ccbi.py`

- Added `ccb_percent()` and routed percent position/size resolution through it
  (§3).
- Added `_is_playable()` and a `playable` flag on every gameplay object (§4.1).
- Added `collect_timeline_overrides()` and `diagnostics.timelineOverrides` (§4.3).
- Added `metadata.playableCollectables` and `diagnostics.parkedObjects` /
  `parkedObjectTotal`.
- Bumped `schemaVersion` to `1.1.0`. All additions are additive, so existing
  Swift `Codable` decoders continue to work unchanged.

`tools/ccbi-converter/verify_levels.py` *(new)*

Standalone verification gate, exits non-zero on failure so it can be wired into
CI. Per level it checks strict JSON validity, schema completeness and types,
absence of `NaN`/`Inf`, coordinate plausibility (parked objects held to a looser
bound), winnability (reachable goal platform + reachable `BigCollectable`),
`topBoundaryY` consistency with the tallest playable object, `timeLimitSeconds`
against the legacy rule, and recognised object kinds. It also independently
re-derives the parked and collectable counts and cross-checks them against the
converter's own numbers, so the two tools cannot drift apart silently.

The verifier was itself negative-tested: a deliberately corrupted level (goal
platform removed, a `NaN` coordinate injected, time limit falsified) is caught
on all counts.

`tools/ccbi-converter/README.md` — documents schema 1.1.0, the parked-object
concept, the truncation rule (with a warning not to "fix" it to rounding), and
the regeneration and verification commands.

## 6. Confidence assessment

**High — this data is good enough to build the game on.**

Supporting evidence:

- Two independent decode paths agree: the `.ccbi` binary parse matches the
  `.ccb` plist source on all 91 levels.
- Coordinate resolution was verified against the actual engine source rather
  than inferred, including the `(int)` truncation, the position/size type enum
  orderings, and the anchor and content-size handling.
- Derived values were re-derived independently by a separate tool and matched:
  time limits against `GameScene.m`, win condition against `Platform.m:247`,
  world-11 background against `BGLayer.m`.
- The data is internally regular in ways a systematic misparse would break
  (exactly 3 big + 1 halo collectable per level in worlds 1–4, exactly one goal
  platform per level, every level's derived time limit matching the legacy
  rule).
- Every anomaly found was traced to a root cause in the original game data and
  explained, rather than filtered out.

Residual risks:

1. **Not play-tested.** Static verification cannot prove a level is *fun* or
   even completable — it proves the geometry is faithfully transcribed and
   structurally sound. Playing through a few levels per world is the remaining
   check.
2. **Behaviour, not just geometry.** This migration covers level *data*. Moving
   platform speeds and paths, enemy AI, and switch/toggle wiring live in the
   original `.m` files and still need porting; the JSON carries the tags and
   kinds needed to drive them.
3. **Viewport choice.** Output is resolved at 320 × 480. Modern devices are
   taller, so the Swift app should scale rather than re-resolve — or regenerate
   with `--viewport` if a different logical size is chosen. Because coordinates
   are resolved at conversion time, changing the target viewport means
   re-running the converter.

### Follow-up needed

`WickedLittleDevilSwift/WickedLittleDevilSwift.xcodeproj/project.pbxproj`
currently references only `Assets.xcassets` in its Resources build phase. The
new `Resources/Levels/` folder is **not yet a member of the app target**, so the
JSON will not be copied into the bundle until it is added. Out of scope here,
but it will need doing before the levels can be loaded at runtime.

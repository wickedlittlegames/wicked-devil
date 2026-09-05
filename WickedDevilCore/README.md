# WickedDevilCore

Engine-agnostic gameplay domain for the Wicked Little Devil rewrite: the 2012
Objective-C/cocos2d game logic ported to plain Swift.

The package depends on **Foundation only** — no SpriteKit, UIKit or cocos2d — so
it builds and tests from the command line and can be driven by any renderer.

## Building and testing

The command-line tools alone do not ship XCTest, so point at the full Xcode:

```bash
cd WickedDevilCore
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

`swift build` works without `DEVELOPER_DIR`.

## Module layout

| File | Contents |
| --- | --- |
| `Geometry.swift` | `Vec2`, `SizeF`, `RectF`. `RectF.centered(at:size:)` encodes cocos2d's default (0.5, 0.5) anchor. |
| `GameConstants.swift` | `GameConstants.h` as Swift statics, plus `AchievementID`, soul/halo `Threshold`s, scoring values and `DeviceProfile` (iPhone 4 vs. iPhone 5 tuning). |
| `Player.swift` | The kinematic player: health/damage, jump/gravity/drag integration, counters, `PlayerAnimation`, `PlayerCharacter`, `Powerup`. |
| `Platform.swift` | `GameEvent`, `PlatformKind` and `Platform` (landing test, bounce, breakables, toggle switches, goal). |
| `NodeMotion.swift` | Ping-pong tween descriptor for moving platforms and mines. |
| `Collectable.swift` | Small/big/halo pickups, magnet attraction, scoring. |
| `Enemy.swift` | Bats, mines, bubbles, rocket launchers, black holes, angel lasers. |
| `Projectile.swift` | Rockets: linear flight and hit tests. |
| `Trigger.swift` | Level triggers and on-screen tips. |
| `Level.swift` | `Codable` level model matching `tools/ccbi-converter` schema 1.1.0, plus factories that build runtime entities. |
| `Game.swift` | Per-run state (`Game`) and end-of-level scoring (`GameResult`). |
| `User.swift` | Persistent profile: souls economy, unlocks, progression, achievements. |
| `UserDataStore.swift` | `UserDataStore` protocol, `UserDefaultsUserDataStore`, `InMemoryUserDataStore`. |
| `GameWorld.swift` | The frame loop from `GameLayer update:`, returning `[GameEvent]`. |

### Typical use

```swift
let user  = User(store: UserDefaultsUserDataStore())
let level = try Level.load(contentsOf: url)
let game  = Game(world: 1, level: 1, player: Player(), user: user)
let world = GameWorld(game: game, level: level, device: .standard)

game.start()
// once per frame:
world.setTouch(touchPoint)
for event in world.update(deltaTime: delta) { /* audio, particles, HUD */ }
```

Side effects the original performed inline (sound, particles, HUD updates) are
returned as `GameEvent` values instead, so the domain layer stays free of
rendering.

## Deliberate deviations from the original

Five original bugs are fixed rather than reproduced; each is commented at the
call site:

1. `Enemy move` tested `position.x > -50` before wrapping a left-moving bat,
   snapping it to the right edge nearly every frame. Ported as `< -50`.
2. `Enemy.m action:` case 2 fell through into case 22, so a stationary mine took
   two health points. Ported as a single hit.
3. `GameLayer.m` rocket handling ran `health--; if (--health <= 0)`, double
   decrementing. Ported as a single hit.
4. `User getHalosforWorld:` read `objectAtIndex:0` instead of the requested
   world. Ported to index the requested world.
5. `check_achiements` compared `getHalosforAll == 80`, which could be missed
   entirely. Widened to `>= 80`.

Interpretations and simplifications:

- **Pixel-perfect collisions.** Enemy hits used a `CCRenderTexture` +
  `glReadPixels` colour test. That is a rendering concern, so the domain layer
  keeps the axis-aligned bounding-box pre-check the original used to gate it.
- **Animations.** `CCAnimation` state became the `PlayerAnimation` enum plus an
  `animating` latch; frame data belongs to the SpriteKit layer.
- **Moving nodes.** `CCRepeatForever(CCSequence(CCMoveBy, reverse))` became
  `NodeMotion`, evaluated analytically per frame. Platforms carrying a motion
  start animating immediately, matching `CCBReader` starting their action at
  load; being hit stops a moving breakable.
- **Camera.** `cameraY` reconstructs the `CCFollow` used by `GameScene`,
  including its `(0, 0, 320, topBoundaryY)` world boundary.
- **Time limit.** Purely a scoring bonus in the original — it never ends a run —
  and the bonus is *not* clamped, so overrunning subtracts points.
- **Parked objects.** Converter schema 1.1.0 marks unreachable off-screen
  objects `playable: false`; `Level.makeEntities()` skips them by default.
- **Dropped integrations.** Parse, Facebook, Flurry and iRate are out of scope
  per project decision; only local logic is ported. `getEquippedPowerup`'s plist
  lookup is a catalogue concern and is not ported either.

## Deferred to the SpriteKit workstream

Sprite atlases and animation frames, particle effects, audio, camera-follow
nodes, the intro tween, touch plumbing, Game Center submission of the
achievement IDs this package unlocks, and the powerup/character catalogues.

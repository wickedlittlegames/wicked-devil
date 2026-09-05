# Legacy asset audit

Written while retiring the 2012 Objective-C/cocos2d project. The purpose is to
prove that every asset the Swift/SpriteKit game needs has been carried across,
so that `Wicked Little Devil/Resources/` can eventually be removed without
losing anything irreplaceable.

Original inventory: **538 files** under `Wicked Little Devil/Resources/`.
New app bundle: **406 files** under `WickedLittleDevilSwift/Resources/`.

## How the new app consumes the original assets

The rewrite deliberately reads the original cocos2d formats rather than
re-cutting them (`Sources/Rendering/SpriteAtlas.swift`):

- A spritesheet is `<name>-hd.png` + `<name>-hd.plist` + `<name>.plist`. The
  retina plist supplies frame rectangles against the retina PNG; the standard
  plist supplies the point size so sprites keep their authored 320x480
  dimensions. The standard-definition **PNG** is therefore not bundled.
- A loose sprite is bundled as `Art/<name>.png` containing the bytes of the
  original `<name>-hd.png`. `SpriteAtlas.image(_:)` halves the pixel size to
  recover points. (`streak3` is the one exception — no retina original exists.)
- UIKit/SwiftUI menu art lives in `MenuAssets.xcassets` as `@1x`/`@2x` pairs
  built from the original standard/`-hd` pair.

## Coverage by category

| Category | Original | Status |
| --- | --- | --- |
| `AUDIO/` (`.caf`, `.aifc`) | 20 | **20/20 copied** to `Resources/Audio/` |
| `FONTS/CrashLandingBB.ttf` | 1 | **copied** to `Resources/Fonts/` |
| `SFX/` particle plists + textures | 14 | **14/14 copied** to `Resources/Particles/` |
| `DATA/LEVELS/*.ccbi` | 91 | **91/91 converted** to `Resources/Levels/*.json` |
| `DATA/LEVEL BUILDER/*.ccb` | 91 | CocosBuilder editor sources; not shipped by the original either |
| `DATA/*.plist` (Characters, Powerups, Powerups_special) | 3 | Transcribed into `Sources/Menus/MenuCatalog.swift` |
| `IMAGES/` | 316 files / 155 logical assets | 94 carried across; 61 deliberately dropped (below) |

Every one of the 91 `.ccbi` level names maps to a `.json` of the same name,
with nothing extra and nothing missing.

## Gaps found and filled

Scanning all 13,892 sprite references across the 91 converted levels against
what the bundle can actually resolve turned up **three loose black-and-white
sprites that were never copied across**. Unresolved frames render as magenta
blocks (`EntityNodeFactory.sprite`), so detective levels (world 20) were
showing placeholder art.

| Asset | Level references | Where it lives now |
| --- | --- | --- |
| `enemy-rocket-target-bw.png` | 20 (world-20-level-9) | `Art/enemy-rocket-target-bw.png` |
| `ingame-mine-bw.png` | 23 (world-20 levels 4, 7, 8) | `Art/ingame-mine-bw.png` |
| `rocket-bw.png` | monochrome twin of the bundled `rocket.png` | `Art/rocket-bw.png` |

`enemy-rocket-target-bw` was the serious one: it exists in no spritesheet, so
deleting `Wicked Little Devil/Resources/` first would have destroyed it.

## Known issues that are *not* asset gaps

Two defects surfaced during the audit. Both are code, and both sit in
directories owned by concurrent work, so they are recorded rather than fixed.

1. **`ingame-small-collectable-bw.png` resolves to magenta in all ten world-20
   levels** (1,698 + 410 references). The frame is present in the bundled
   `IngameSprites-bw` atlas, but 410 references name `IngameSprites.plist` as
   their sheet. cocos2d used a single global `CCSpriteFrameCache`, so the sheet
   a `.ccbi` named never mattered; `SpriteAtlas.frame(named:sheet:)` takes the
   sheet literally and falls back only to `IngameSprites`. The fix is a further
   fallback that searches every loaded atlas by frame name. No art is missing.

2. **`StatsView.swift` requests `bg-stats-iphone5`**, which has never existed —
   not in the new bundle and not in the 2012 project. The stats screen simply
   draws no background. Some other background needs choosing.

## Deliberately dropped (61 logical assets)

None of these are referenced by the new app, in level data or in code.

- **iOS chrome superseded by modern equivalents (4):** `Default`,
  `Default-568h`, `Icon`, `iTunesArtwork` — replaced by the generated launch
  screen and the `AppIcon` set in `Assets.xcassets`.
- **`BlockUI` alert/action-sheet skin (15):** `action-*`, `alert-*`. Chrome for
  the third-party `BlockAlertView`/`BlockActionSheet` UIKit library, which the
  rewrite does not use.
- **Facebook, Twitter and Game Center UI (13):** `bg-facebookfriends`,
  `bg-menu-facebook`, `ui-prompt-facebook`, `btn-fb`, `btn-fb-score`,
  `btn-behind-fb`, `btn-invitefriends`, `btn-tweet-score`, `btn-secret-like`,
  `btn-achievements`, `btn-gamecenter`, `btn-leaderboard`, `btn-more-games` —
  dropped with the SDKs, per the "core gameplay + local progress only" decision.
- **Unported screens and features (29):** the in-app purchase and second-chance
  flow (`btn-second-chance`, `btn-secret-play`, `bg-pulldown`,
  `bg-powerups-menu`, `bg-store-home`), the pause overlay art
  (`bg-pauseoverlay`, `-iphone5`), the pre-level tutorial overlays
  (`tip-world-*` x9, `tip-beginners1/2`, `tip-ok`), superseded iPhone 5
  letterbox backgrounds (`bg_1-iphone5`, `bg_2-iphone5`, `bg_20`), and unused
  character stills (`angel-dev-ingame`, `arrow-med`, `ninjadevil`,
  `pirate-jump1`, `zombie-jump1`, `pixel-devil-game`, `pixel-devil-store-`).

The tutorial overlays are the only group representing a real original feature
that was not ported. They are worth keeping in mind if pre-level tips are ever
revived; until then they are recoverable from git history.

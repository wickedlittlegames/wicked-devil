# Legacy asset audit

Written while retiring the 2012 Objective-C/cocos2d project. The purpose is to
prove that every asset the Swift/SpriteKit game needs has been carried across,
so that `Wicked Little Devil/Resources/` can eventually be removed without
losing anything irreplaceable.

Original inventory: **538 files** under `Wicked Little Devil/Resources/`.
New app bundle: **421 files** under `WickedLittleDevilSwift/Resources/`.

The new app is still actively drawing on the original — the pre-level tutorial
overlays were ported *during* this audit. Treat the figures below as a snapshot
and re-run the check before deleting anything.

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
| `IMAGES/` | 316 files / 155 logical assets | 104 carried across; 51 not yet needed (below) |

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

Two defects surfaced during the audit. Both are code rather than missing art,
and both sit in directories owned by concurrent gameplay-polish work, so they
were recorded here rather than fixed in place. **Both have since been handed to
the polish agent**; this section is the record of where they were found, not an
open action.

1. **`ingame-small-collectable-bw.png` resolves to magenta in all ten world-20
   levels** (1,698 + 410 references). The frame is present in the bundled
   `IngameSprites-bw` atlas, but 410 references name `IngameSprites.plist` as
   their sheet. cocos2d used a single global `CCSpriteFrameCache`, so the sheet
   a `.ccbi` named never mattered; `SpriteAtlas.frame(named:sheet:)` takes the
   sheet literally and falls back only to `IngameSprites`. The fix is a further
   fallback that searches every loaded atlas by frame name. No art is missing.
   *Owner: gameplay-polish agent (`Sources/Rendering/SpriteAtlas.swift`).*

2. **`StatsView.swift` requests `bg-stats-iphone5`**, which has never existed —
   not in the new bundle and not in the 2012 project. The stats screen simply
   draws no background. Some other background needs choosing.
   *Owner: gameplay-polish agent (`Sources/Menus/StatsView.swift`).*

## Not carried across (51 logical assets)

None of these are currently referenced by the new app, in level data or in code.
Two of the four groups are dead for good; the fourth is only dead *for now*.

**Obsolete — safe to lose (16)**

- *iOS chrome superseded by modern equivalents (4):* `Default`, `Default-568h`,
  `Icon`, `iTunesArtwork` — replaced by the generated launch screen and the
  `AppIcon` set in `Assets.xcassets`.
- *`BlockUI` alert/action-sheet skin (12):* `action-*` (7), `alert-*` (5).
  Chrome for the third-party `BlockAlertView`/`BlockActionSheet` UIKit library,
  which the rewrite does not use.

**Dropped by product decision (13)**

Facebook, Twitter and Game Center UI: `bg-facebookfriends`, `bg-menu-facebook`,
`ui-prompt-facebook`, `btn-fb`, `btn-fb-score`, `btn-behind-fb`,
`btn-invitefriends`, `btn-tweet-score`, `btn-secret-like`, `btn-achievements`,
`btn-gamecenter`, `btn-leaderboard`, `btn-more-games` — dropped alongside the
SDKs, per the "core gameplay + local progress only" decision.

**Unported features — still plausible future needs (22)**

- In-app purchase and second-chance flow: `btn-second-chance`, `btn-secret-play`,
  `bg-pulldown`, `bg-powerups-menu`, `bg-store-home`, `ui-btn-devilupgrades`,
  `ui-btn-specialupgrades`, `ui-btn-home-flag`.
- Pause overlay backdrop: `bg-pauseoverlay`, `bg-pauseoverlay-iphone5`. The
  pause *button* has been ported; the overlay art has not.
- Remaining tutorial art: `tip-beginners1`, `tip-beginners2`.
- Superseded iPhone 5 letterbox backgrounds: `bg_1-iphone5`, `bg_2-iphone5`,
  `bg_20`.
- Unused character stills: `angel-dev-ingame`, `arrow-med`, `ninjadevil`,
  `pirate-jump1`, `zombie-jump1`, `pixel-devil-game`, `pixel-devil-store-`.

This last group is the reason `Wicked Little Devil/Resources/` should outlive
the Objective-C sources. Nine of the tutorial overlays moved from this list into
the bundle while the audit was being written.

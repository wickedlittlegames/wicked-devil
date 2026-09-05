# Wicked Little Devil

A 2012 iPhone game, rewritten. The original was Objective-C on cocos2d 1.x with
levels authored in CocosBuilder; this repository now holds a Swift + SpriteKit
port that plays the same 91 levels from the same original art and level data.

## Layout

| Path | What it is |
| --- | --- |
| `WickedLittleDevilSwift/` | The iOS app: SpriteKit gameplay, SwiftUI menus, and the bundled resources. Project file is generated from `project.yml` by XcodeGen. |
| `WickedDevilCore/` | Engine-agnostic gameplay domain as a Swift package. Foundation only — no SpriteKit or UIKit — so it builds and tests from the command line. See its own README. |
| `tools/ccbi-converter/` | Python converter that reads the original binary `.ccbi` levels and emits the JSON the app ships, plus verification scripts and a migration report. |
| `tools/menu-assets/` | Scripts that build the menu asset catalogues from the original art. |
| `Design Assets/` | Original source art: layered PSDs and media. Not built into anything. |
| `Wicked Little Devil/` | The 2012 Objective-C sources and the original resource tree. Reference material — see below. |
| `Wicked Little Devil.xcodeproj` | The 2012 Xcode project. No longer buildable; see below. |
| `docs/` | Notes produced during the rewrite, including the legacy asset audit. |

## Building

The command-line tools do not ship XCTest, so point at the full Xcode:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

cd WickedDevilCore && swift test

cd WickedLittleDevilSwift
xcodebuild -project WickedLittleDevilSwift.xcodeproj \
  -scheme WickedLittleDevilSwift -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' build
```

## The 2012 project

The original is kept for reference, not for building. It is the only
specification of some original behaviour, and questions about the port have
repeatedly been settled by reading it — bubble-grab semantics in `Enemy.m`,
touch handling in `GameScene.m`, coordinate truncation in
`CCNode+CCBRelativePositioning.m`.

Two things about it are worth knowing:

- **It no longer builds.** The Parse, Facebook, Flurry, iRate and OpenUDID
  dependencies have been deleted (Parse's backend shut down in 2017 and the
  bundled Facebook SDK is a 2013 build), and `project.pbxproj` still references
  them. Progression in the rewrite is entirely local, via `WickedDevilCore`'s
  `User` and `UserDefaultsUserDataStore`, so nothing was lost.
- **`Resources/DATA/LEVELS/*.ccbi` is irreplaceable.** Those 91 binary files are
  the authored source for every level in the game and the input to the
  converter. Nothing regenerates them.

`docs/legacy-asset-audit.md` records which original assets the new app uses and
which it does not, and should be re-run before anything under
`Wicked Little Devil/Resources/` is removed.

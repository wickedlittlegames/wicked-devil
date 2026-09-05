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
| `legacy-reference/` | The 2012 Objective-C sources and the original resource tree. Reference material, excluded from every build — see below and its own README. |
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

`legacy-reference/` holds the original sources and resource tree. It is kept for
reference, not for building: the Xcode project, the vendored cocos2d/CCBReader
libraries and the dead third-party SDKs (Parse, Facebook, Flurry, iRate,
OpenUDID) have all been deleted, and nothing in the repo builds from it.

It stays because it is the only specification of some original behaviour, and
questions about the port have repeatedly been settled by reading it —
bubble-grab semantics in `Enemy.m`, touch handling in `GameScene.m`, coordinate
truncation in `CCNode+CCBRelativePositioning.m`.

**`legacy-reference/Resources/DATA/LEVELS/*.ccbi` is irreplaceable.** Those 91
binary files are the authored source for every level in the game and the input
to `tools/ccbi-converter/`. Nothing regenerates them.

`docs/legacy-asset-audit.md` records which original assets the new app uses and
which it does not, and should be re-run before anything under
`legacy-reference/Resources/` is removed.

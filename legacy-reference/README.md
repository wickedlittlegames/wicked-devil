# Legacy reference — the 2012 Objective-C game

This is the original *Wicked Little Devil*: the cocos2d/Objective-C sources and
the resource tree they shipped with. It was moved here from `Wicked Little
Devil/` when the Swift + SpriteKit rewrite took over.

**Nothing here is built.** The Xcode project, the vendored libraries (`libs/`:
cocos2d, CCBReader, CCControlExtension) and the dead third-party SDKs (Parse,
Facebook, Flurry, iRate, OpenUDID) have all been deleted. No target, scheme,
script or `project.yml` in this repo references this directory except the
conversion tooling described below. It is documentation that happens to compile
in 2012.

## Why it is still here

It is the authoritative specification of original game behaviour. The rewrite
had to reproduce a lot of undocumented, emergent detail, and the only way to
settle those questions was to read this code. It has been used repeatedly and
in anger, not kept as a curiosity:

- **`Objects/Enemy.m:166`** — bubble-grab semantics. Exactly when a bubble
  captures the player, and what happens to an enemy already holding one.
- **`Scenes/Gameplay/GameScene.m:262`** — touch handling. How a touch maps to
  movement, and the ordering that makes flicks feel the way they do.
- **`CCNode+CCBRelativePositioning.m:41`** — coordinate truncation. CocosBuilder
  relative positions are truncated, not rounded, which shifts geometry by a
  pixel in places and matters when comparing converted levels against the
  original. *This file lived in the now-deleted `libs/CCBReader/`; recover it
  from git history (`git log --all -- '*CCBRelativePositioning*'`) if needed.*

Two further behaviours were pinned down here after the move and are recorded in
`docs/legacy-asset-audit.md`: cocos2d's sprite-frame lookup being global rather
than per-sheet (`libs/CCBReader/CCBReader.m:415-423`, also deleted), and the
Stats screen reusing the Store background (`Scenes/StatsScene.m:70`).

## The irreplaceable part

`Resources/DATA/LEVELS/*.ccbi` — **91 compiled CocosBuilder files**. These are
the authored source for every level in the game. Nothing regenerates them; they
are the one thing in this repo that could not be reconstructed. They are the
input to the level pipeline in **`tools/ccbi-converter/`**, which parses the
binary format directly and emits the JSON the Swift app ships. Re-running the
converter over this directory reproduces `WickedLittleDevilSwift/Resources/Levels/`
byte for byte.

`Resources/DATA/LEVEL BUILDER/*.ccb` holds the matching uncompiled sources, used
by the converter's `--validate-with-ccb` cross-check.

## The rest of the resource tree

`Resources/IMAGES`, `SOUNDS` and `FONTS` are the original art, audio and the
`CrashLandingBB` font. The Swift app does **not** read from here at runtime — it
bundles its own copies under `WickedLittleDevilSwift/Resources/` — but this is
where they came from, and the audit in `docs/legacy-asset-audit.md` proves which
ones were carried across and which were deliberately left behind.

If you need an asset that isn't in the app yet, it is here. Read the audit
first: the naming convention is not obvious (loose sprites are bundled from the
original `-hd` file with the suffix dropped, and the app parses the original
cocos2d `.plist` atlases at runtime).

## Before deleting any of this

Re-run the resolvability audit described in `docs/legacy-asset-audit.md`. It
exists because a plain "is it referenced?" scan was not sufficient:
`enemy-rocket-target-bw.png` appears in no atlas plist and existed only as a
loose PNG here, and deleting this tree in the obvious order would have silently
destroyed a live asset.

#!/usr/bin/env python3
"""Copy the original game's menu art into the Swift app's asset catalog.

The 2012 game shipped 1x art as `<name>.png` and retina art as either
`<name>-hd.png` or `<name>@2x.png`. This script pairs those up into
`.imageset` folders inside `Resources/MenuAssets.xcassets`, so SwiftUI can
reference them with plain `Image("<name>")`.

The original `Wicked Little Devil/` tree is read-only: nothing is written
back into it.

Usage: python3 tools/menu-assets/import_menu_assets.py
"""

import json
import os
import shutil
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ORIGINAL = os.path.join(REPO, "Wicked Little Devil", "Resources", "IMAGES")
CATALOG = os.path.join(
    REPO, "WickedLittleDevilSwift", "Resources", "MenuAssets.xcassets"
)
FONT_SRC = os.path.join(REPO, "Wicked Little Devil", "Resources", "FONTS")
FONT_DST = os.path.join(REPO, "WickedLittleDevilSwift", "Resources", "Fonts")

# Base names to import, grouped only for readability. `-iphone5` variants are
# taller 320x568 backgrounds; we prefer those for full-bleed backgrounds since
# modern devices are taller still.
NAMES = [
    # Backgrounds
    "bg-home", "bg-home-iphone5",
    "bg-menu-hell", "bg-menu-underground", "bg-menu-ocean", "bg-menu-land",
    "bg-menu-detective", "bg-coming-soon",
    "bg-world-1", "bg-world-2", "bg-world-3", "bg-world-4", "bg-world-20",
    "bg-store", "bg-store-iphone5", "bg-store-home-iphone5",
    "bg-gameover-1", "bg-gameover-2", "bg-gameover-3",
    "bg-gameover-1-iphone5", "bg-gameover-2-iphone5", "bg-gameover-3-iphone5",
    "bg-locked", "bg-locked-iphone5",
    "bg-topbar", "bg-topbar-bw",
    # Buttons
    "btn-start", "title-adventures", "title-adventures-new",
    "btn-back", "btn-back-bw", "btn-stats", "btn-powerup", "btn-store-world",
    "btn-level", "btn-level-locked", "btn-level-bw", "btn-skip",
    "btn-unlock-detective", "btn-nextlevel", "btn-reply", "btn-levelselect",
    "btn-devil-upgrades", "btn-special-upgrades", "btn-character-upgrades",
    "btn-purchase-souls", "btn-unequip-all", "btn-equipequipped",
    "btn-equippurchase", "btn-purchase",
    "btn-mute", "btn-muted", "btn-gameplay-menu", "btn-pause",
    # Icons / HUD
    "icon-bigcollectable", "icon-bigcollectable-bw",
    "icon-bigcollectable-med", "icon-bigcollectable-med-bw",
    "icon-bigcollectable-empty",
    "icon-halo-med",
    "icon-level-bigcollectable", "icon-level-bigcollectable-bw",
    "icon-level-halo",
    "ui-collectable", "ui-collectable-bw", "ui-newhighscore", "ui-spinner-fx",
    "ANGEL-DEVIL",
    # Character shop portraits
    "character-unlock-detective", "pixel-devil-store-", "zombie-devil",
    "ninjadevil-store", "pirate-shop",
]

# Asset-catalog names may not contain characters that are awkward in Swift
# string literals; the trailing hyphen on `pixel-devil-store-` is the only
# oddity in the original set.
RENAMES = {"pixel-devil-store-": "pixel-devil-store"}


def find(basename, retina):
    """Locate a source PNG anywhere under the original IMAGES tree."""
    candidates = (
        ["%s-hd.png" % basename, "%s@2x.png" % basename]
        if retina
        else ["%s.png" % basename]
    )
    for root, _dirs, files in os.walk(ORIGINAL):
        for candidate in candidates:
            if candidate in files:
                return os.path.join(root, candidate)
    return None


def write_catalog_root():
    os.makedirs(CATALOG, exist_ok=True)
    with open(os.path.join(CATALOG, "Contents.json"), "w") as handle:
        json.dump(
            {"info": {"author": "xcode", "version": 1}}, handle, indent=2
        )
        handle.write("\n")


def import_image(basename):
    one_x = find(basename, retina=False)
    two_x = find(basename, retina=True)
    if one_x is None and two_x is None:
        return None

    asset_name = RENAMES.get(basename, basename)
    imageset = os.path.join(CATALOG, "%s.imageset" % asset_name)
    os.makedirs(imageset, exist_ok=True)

    images = []
    for scale, source in (("1x", one_x), ("2x", two_x)):
        entry = {"idiom": "universal", "scale": scale}
        if source:
            filename = "%s@%s.png" % (asset_name, scale)
            shutil.copyfile(source, os.path.join(imageset, filename))
            entry["filename"] = filename
        images.append(entry)
    # A 3x slot keeps Xcode quiet; the 2x art is upscaled at runtime.
    images.append({"idiom": "universal", "scale": "3x"})

    with open(os.path.join(imageset, "Contents.json"), "w") as handle:
        json.dump(
            {
                "images": images,
                "info": {"author": "xcode", "version": 1},
            },
            handle,
            indent=2,
        )
        handle.write("\n")
    return asset_name


def import_fonts():
    os.makedirs(FONT_DST, exist_ok=True)
    copied = []
    if not os.path.isdir(FONT_SRC):
        return copied
    for name in sorted(os.listdir(FONT_SRC)):
        if name.lower().endswith((".ttf", ".otf")):
            shutil.copyfile(
                os.path.join(FONT_SRC, name), os.path.join(FONT_DST, name)
            )
            copied.append(name)
    return copied


def main():
    if not os.path.isdir(ORIGINAL):
        sys.exit("Original IMAGES folder not found at %s" % ORIGINAL)

    write_catalog_root()
    imported, missing = [], []
    for basename in NAMES:
        result = import_image(basename)
        (imported if result else missing).append(basename)

    print("Imported %d imagesets into %s" % (len(imported), CATALOG))
    if missing:
        print("Missing source art for: %s" % ", ".join(missing))
    print("Fonts copied: %s" % (", ".join(import_fonts()) or "none"))


if __name__ == "__main__":
    main()

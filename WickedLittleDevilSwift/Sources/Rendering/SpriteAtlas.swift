import CoreGraphics
import os
import SpriteKit
import UIKit

/// A TexturePacker / cocos2d `.plist` spritesheet, read at runtime.
///
/// The 2012 game shipped its art as `<name>.plist` + `<name>.png` pairs with a
/// retina `<name>-hd` variant. Rather than re-cutting them into `.atlas`
/// folders (which would re-encode the PNGs and lose the authored packing), the
/// plists are parsed as-is and each frame becomes an `SKTexture` sub-rect of
/// the retina sheet.
///
/// Frame rectangles come from the `-hd` plist (they address the retina PNG),
/// while the point size of a frame comes from the standard-definition plist so
/// sprites keep the exact 320x480 point dimensions the levels were authored
/// against. Where no SD plist exists the retina size is simply halved.
final class SpriteAtlas {

    struct Frame {
        /// Sub-rect texture cut from the sheet.
        let texture: SKTexture
        /// Size in points (retina pixels / 2).
        let size: CGSize
    }

    let name: String
    private let frames: [String: Frame]

    private init(name: String, frames: [String: Frame]) {
        self.name = name
        self.frames = frames
    }

    // MARK: - Lookup

    func frame(_ name: String) -> Frame? {
        frames[name] ?? frames[name.deletingPNGExtension] ?? frames[name + ".png"]
    }

    /// Frames named `<prefix><index>.png` for `index` in `1...count`, in order.
    func animationFrames(prefix: String, count: Int) -> [Frame] {
        guard count > 0 else { return [] }
        return (1...count).compactMap { frame("\(prefix)\($0).png") }
    }

    var frameNames: [String] { Array(frames.keys) }

    // MARK: - Loading

    private static var cache: [String: SpriteAtlas?] = [:]

    /// Loads (and caches) an atlas by its logical name, e.g. `IngameSprites`.
    static func named(_ name: String) -> SpriteAtlas? {
        if let cached = cache[name] { return cached }
        let atlas = load(name: name)
        cache[name] = atlas
        return atlas
    }

    /// Every spritesheet in the bundle, in a stable order.
    ///
    /// Sheets ship as a `<name>-hd.plist` / `<name>-hd.png` pair; the particle
    /// and level plists have no `-hd` variant, so the suffix is enough to tell
    /// them apart.
    static let bundledSheetNames: [String] = {
        AssetLocator.urls(forResourcesWithExtension: "plist")
            .map { $0.deletingPathExtension().lastPathComponent }
            .filter { $0.hasSuffix("-hd") }
            .map { String($0.dropLast(3)) }
            .sorted()
    }()

    /// Finds a frame in any bundled sheet other than `excluding`.
    ///
    /// This is the global `CCSpriteFrameCache` behaviour — see the note on
    /// `SpriteLibrary.frame(named:sheet:)`.
    static func searchAllSheets(for frameName: String, excluding: Set<String>) -> (atlas: SpriteAtlas, frame: Frame)? {
        for sheetName in bundledSheetNames where !excluding.contains(sheetName) {
            if let atlas = named(sheetName), let frame = atlas.frame(frameName) {
                return (atlas, frame)
            }
        }
        return nil
    }

    private static func load(name: String) -> SpriteAtlas? {
        guard let retinaPlist = AssetLocator.plist(named: "\(name)-hd"),
              let imageURL = AssetLocator.url(forResource: "\(name)-hd", withExtension: "png"),
              let image = UIImage(contentsOfFile: imageURL.path)
        else { return nil }

        let sheet = SKTexture(image: image)
        let sheetSize = CGSize(width: image.size.width * image.scale,
                               height: image.size.height * image.scale)
        guard sheetSize.width > 0, sheetSize.height > 0 else { return nil }

        let retinaFrames = retinaPlist["frames"] as? [String: Any] ?? [:]
        let pointFrames = AssetLocator.plist(named: name)?["frames"] as? [String: Any]

        var built: [String: Frame] = [:]
        built.reserveCapacity(retinaFrames.count)

        for (frameName, raw) in retinaFrames {
            guard let entry = raw as? [String: Any],
                  let rectString = (entry["textureRect"] as? String) ?? (entry["frame"] as? String),
                  let pixelRect = CGRect(cocosString: rectString)
            else { continue }

            let rotated = (entry["textureRotated"] as? Bool) ?? (entry["rotated"] as? Bool) ?? false
            // A rotated frame is stored 90 degrees clockwise, so the packed
            // rectangle has its width and height swapped.
            let packed = rotated
                ? CGRect(x: pixelRect.minX, y: pixelRect.minY,
                         width: pixelRect.height, height: pixelRect.width)
                : pixelRect

            // Plist rects are top-left origin; SKTexture wants a normalised
            // bottom-left origin rect.
            let normalised = CGRect(
                x: packed.minX / sheetSize.width,
                y: (sheetSize.height - packed.maxY) / sheetSize.height,
                width: packed.width / sheetSize.width,
                height: packed.height / sheetSize.height
            )
            guard normalised.width > 0, normalised.height > 0 else { continue }

            let pointSize: CGSize
            if let sd = pointFrames?[frameName] as? [String: Any],
               let sdSize = (sd["spriteSourceSize"] as? String).flatMap(CGSize.init(cocosString:)) {
                pointSize = sdSize
            } else {
                pointSize = CGSize(width: pixelRect.width / 2, height: pixelRect.height / 2)
            }

            built[frameName] = Frame(
                texture: SKTexture(rect: normalised, in: sheet),
                size: pointSize
            )
        }

        guard !built.isEmpty else { return nil }
        return SpriteAtlas(name: name, frames: built)
    }
}

// MARK: - Standalone images

enum SpriteLibrary {
    private static var cache: [String: SpriteAtlas.Frame?] = [:]

    /// Loads a loose retina PNG (already copied in without its `-hd` suffix)
    /// and reports it at half size so it lands in the 320x480 point space.
    static func image(named name: String) -> SpriteAtlas.Frame? {
        if let cached = cache[name] { return cached }
        let frame: SpriteAtlas.Frame?
        if let url = AssetLocator.url(forResource: name.deletingPNGExtension, withExtension: "png"),
           let image = UIImage(contentsOfFile: url.path) {
            let pixels = CGSize(width: image.size.width * image.scale,
                                height: image.size.height * image.scale)
            frame = SpriteAtlas.Frame(
                texture: SKTexture(image: image),
                size: CGSize(width: pixels.width / 2, height: pixels.height / 2)
            )
        } else {
            frame = nil
        }
        cache[name] = frame
        return frame
    }

    /// Resolves a level object's `spriteFrame`/`spriteSheet` pair.
    ///
    /// The declared sheet is not always the one holding the frame. `CCBReader.m:415-423`
    /// loaded whatever sheet the level named into the *shared*
    /// `CCSpriteFrameCache` and then asked for the frame by name alone, so once
    /// any sheet in the session had been loaded its frames resolved for every
    /// node regardless of what that node declared. CocosBuilder let authors
    /// leave a stale sheet on a node and the game never noticed.
    ///
    /// World 20 relies on exactly that: 410 of its `ingame-small-collectable-bw.png`
    /// nodes name `IngameSprites.plist`, while the frame only exists in
    /// `IngameSprites-bw`. A strict per-sheet lookup drew them magenta.
    ///
    /// So the declared sheet is tried first, then the rest of the bundle, and
    /// only then a loose PNG. Falling back is logged: art that is genuinely
    /// absent should still surface as a problem rather than be papered over.
    static func frame(named frameName: String, sheet: String?) -> SpriteAtlas.Frame? {
        let declared = sheet?.deletingPlistExtension
        if let declared, let atlas = SpriteAtlas.named(declared), let frame = atlas.frame(frameName) {
            return frame
        }

        var tried: Set<String> = []
        if let declared { tried.insert(declared) }

        if let found = SpriteAtlas.searchAllSheets(for: frameName, excluding: tried) {
            reportSheetMismatch(frame: frameName, declared: declared, found: found.atlas.name)
            return found.frame
        }

        return image(named: frameName)
    }

    private static let log = Logger(subsystem: "com.wickedlittlewebsites.wickeddevil.swift",
                                    category: "SpriteAtlas")
    private static var reportedMismatches: Set<String> = []

    /// Logs each distinct mismatch once — world 20 alone would otherwise emit
    /// hundreds of identical lines per level.
    private static func reportSheetMismatch(frame: String, declared: String?, found: String) {
        let key = "\(declared ?? "-")|\(frame)"
        guard reportedMismatches.insert(key).inserted else { return }
        log.notice("""
            Sprite frame \(frame, privacy: .public) is declared in \
            \(declared ?? "no sheet", privacy: .public) but was found in \
            \(found, privacy: .public); resolving it the way cocos2d's shared \
            frame cache would.
            """)
    }
}

// MARK: - Bundle lookup

/// Resources are added to the app as folder references, so lookups have to try
/// the known subdirectories as well as the bundle root.
enum AssetLocator {
    static let subdirectories = ["Art", "Audio", "Particles", "Fonts", "Levels"]

    static func url(forResource name: String, withExtension ext: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: ext) { return url }
        for subdirectory in subdirectories {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: subdirectory) {
                return url
            }
        }
        return nil
    }

    /// Every bundled resource with the given extension, across the root and the
    /// known folder references.
    static func urls(forResourcesWithExtension ext: String) -> [URL] {
        var found = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? []
        for subdirectory in subdirectories {
            found += Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: subdirectory) ?? []
        }
        return found
    }

    static func plist(named name: String) -> [String: Any]? {
        guard let url = url(forResource: name, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil)
        else { return nil }
        return plist as? [String: Any]
    }
}

// MARK: - cocos2d geometry strings

extension String {
    var deletingPNGExtension: String {
        hasSuffix(".png") ? String(dropLast(4)) : self
    }

    var deletingPlistExtension: String {
        hasSuffix(".plist") ? String(dropLast(6)) : self
    }

    fileprivate var cocosNumbers: [CGFloat] {
        split(whereSeparator: { "{}, ".contains($0) })
            .compactMap { Double($0).map { CGFloat($0) } }
    }
}

extension CGRect {
    /// Parses `{{x, y}, {w, h}}`.
    fileprivate init?(cocosString: String) {
        let values = cocosString.cocosNumbers
        guard values.count == 4 else { return nil }
        self.init(x: values[0], y: values[1], width: values[2], height: values[3])
    }
}

extension CGSize {
    /// Parses `{w, h}`.
    fileprivate init?(cocosString: String) {
        let values = cocosString.cocosNumbers
        guard values.count == 2 else { return nil }
        self.init(width: values[0], height: values[1])
    }
}

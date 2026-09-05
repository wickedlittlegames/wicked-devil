import Foundation
import WickedDevilCore

/// Finds and decodes the converted level JSON bundled with the app.
enum LevelCatalog {

    static func filename(world: Int, level: Int) -> String {
        "world-\(world)-level-\(level)"
    }

    static func url(world: Int, level: Int) -> URL? {
        AssetLocator.url(forResource: filename(world: world, level: level), withExtension: "json")
    }

    static func load(world: Int, level: Int) throws -> Level {
        guard let url = url(world: world, level: level) else {
            throw LevelCatalogError.missing(world: world, level: level)
        }
        return try Level.load(contentsOf: url)
    }

    /// The background image `BGLayer createWorldSpecificBackgrounds:` picked.
    /// The bonus world reuses world 1's artwork.
    static func backgroundImage(world: Int) -> String {
        world == GameConstants.bonusWorld ? "bg-world-1" : "bg-world-\(world)"
    }

    /// `GameScene.m`: world 20 is silent, the bonus world uses the menu track.
    static func musicTrack(world: Int) -> String? {
        switch world {
        case GameConstants.detectiveWorld: return nil
        case GameConstants.bonusWorld: return "bg-main.aifc"
        default: return "bg-loop\(world).aifc"
        }
    }
}

enum LevelCatalogError: LocalizedError {
    case missing(world: Int, level: Int)

    var errorDescription: String? {
        switch self {
        case let .missing(world, level):
            return "world-\(world)-level-\(level).json is not in the app bundle"
        }
    }
}

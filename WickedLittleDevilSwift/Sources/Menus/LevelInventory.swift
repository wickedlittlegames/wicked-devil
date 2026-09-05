import Foundation
import WickedDevilCore

/// Which worlds and levels actually exist as playable content.
///
/// The 2012 game was scoped for `WORLDS_PER_GAME` (12) worlds of
/// `LEVELS_PER_WORLD` (20) levels, but only ever shipped four of them plus two
/// side campaigns. Converting the original `.ccbi` files produced **91**
/// levels:
///
/// | World | Levels | Notes |
/// | --- | --- | --- |
/// | 1–4 | 20 each | the main "adventure" |
/// | 11 | 1 | the hidden bonus level `StartScene.m` unlocked |
/// | 20 | 10 | the Detective Devil campaign |
///
/// Worlds 5–12 were never authored. `GameConstants.detectiveLevelCount` says
/// 12 detective levels, but only 10 `.ccbi` files existed, so the UI trusts the
/// inventory rather than the constant.
///
/// The inventory is discovered from the bundled level JSON at launch so that
/// adding levels needs no code change; `shipped` is the compile-time fallback
/// used by previews and by any build where the resource folder is missing.
struct LevelInventory: Sendable, Equatable {
    /// Level counts keyed by world number.
    let levelCounts: [Int: Int]

    init(levelCounts: [Int: Int]) {
        self.levelCounts = levelCounts
    }

    /// The 91 levels produced by the `.ccbi` conversion.
    static let shipped = LevelInventory(levelCounts: [
        1: GameConstants.levelsPerWorld,
        2: GameConstants.levelsPerWorld,
        3: GameConstants.levelsPerWorld,
        4: GameConstants.levelsPerWorld,
        GameConstants.bonusWorld: 1,
        GameConstants.detectiveWorld: 10,
    ])

    /// What the bundle lookup actually found, before the `shipped` fallback is
    /// applied. Empty means the resource lookup failed.
    static let discoveredFromBundle: LevelInventory = discoverFromBundle()

    /// Discovered from `Levels/world-<W>-level-<L>.json` in the app bundle,
    /// falling back to `shipped` when nothing is found (previews, tests).
    static let bundled: LevelInventory = {
        let discovered = discoveredFromBundle
        return discovered.levelCounts.isEmpty ? shipped : discovered
    }()

    private static func discoverFromBundle() -> LevelInventory {
        let urls = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Levels") ?? [])
            + (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])

        var highest: [Int: Int] = [:]
        for url in urls {
            guard let (world, level) = Self.parse(fileName: url.deletingPathExtension().lastPathComponent) else { continue }
            highest[world] = max(highest[world] ?? 0, level)
        }
        return LevelInventory(levelCounts: highest)
    }

    /// Parses `world-3-level-17` into `(3, 17)`.
    static func parse(fileName: String) -> (world: Int, level: Int)? {
        let parts = fileName.split(separator: "-")
        guard parts.count == 4,
              parts[0] == "world", parts[2] == "level",
              let world = Int(parts[1]), let level = Int(parts[3])
        else { return nil }
        return (world, level)
    }

    /// The main-campaign worlds, in order. Bounded by
    /// `GameConstants.currentWorldsPerGame` because progression, achievements
    /// and the "souls collected out of N" totals are all defined against it.
    var adventureWorlds: [Int] {
        (1...GameConstants.currentWorldsPerGame).filter { levelCount(world: $0) > 0 }
    }

    /// Worlds that were designed but never authored — shown as "coming soon".
    var comingSoonWorldCount: Int {
        max(0, GameConstants.worldsPerGame - GameConstants.currentWorldsPerGame)
    }

    func levelCount(world: Int) -> Int { levelCounts[world] ?? 0 }

    func levels(world: Int) -> [Int] {
        let count = levelCount(world: world)
        return count > 0 ? Array(1...count) : []
    }

    func hasLevel(world: Int, level: Int) -> Bool {
        level >= 1 && level <= levelCount(world: world)
    }

    var detectiveLevelCount: Int { levelCount(world: GameConstants.detectiveWorld) }

    var hasBonusLevel: Bool {
        hasLevel(world: GameConstants.bonusWorld, level: GameConstants.bonusLevel)
    }

    /// Three big souls are hidden in every level.
    static let soulsPerLevel = 3
    /// One halo is hidden in every main-campaign level.
    static let halosPerLevel = 1

    func soulsAvailable(world: Int) -> Int { levelCount(world: world) * Self.soulsPerLevel }
    func halosAvailable(world: Int) -> Int { levelCount(world: world) * Self.halosPerLevel }

    /// Totals across the main campaign, matching the original's
    /// `LEVELS_PER_WORLD * CURRENT_WORLDS_PER_GAME * 3` and `* 1` counters.
    var totalAdventureSouls: Int {
        adventureWorlds.reduce(0) { $0 + soulsAvailable(world: $1) }
    }

    var totalAdventureHalos: Int {
        adventureWorlds.reduce(0) { $0 + halosAvailable(world: $1) }
    }
}

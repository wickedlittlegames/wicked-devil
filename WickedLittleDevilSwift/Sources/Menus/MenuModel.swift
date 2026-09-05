import Foundation
import Observation
import WickedDevilCore

/// A level's best result, as shown on the level-select grid.
struct LevelSummary: Identifiable, Hashable, Sendable {
    let world: Int
    let level: Int
    let isUnlocked: Bool
    /// 0...3 big souls found.
    let soulsEarned: Int
    /// 0...1 halo found. Always 0 for the detective campaign, which does not
    /// track halos.
    let halosEarned: Int
    let highScore: Int

    var id: String { "\(world)-\(level)" }
    var isComplete: Bool { highScore > 0 }
}

/// A world's aggregate progress, as shown on the world-select carousel.
struct WorldSummary: Identifiable, Hashable, Sendable {
    let world: Int
    let theme: WorldTheme
    let isUnlocked: Bool
    let levels: [LevelSummary]
    let soulsEarned: Int
    let soulsAvailable: Int
    let halosEarned: Int
    let halosAvailable: Int
    let highScore: Int

    var id: Int { world }
    var completedLevels: Int { levels.filter(\.isComplete).count }
    var levelCount: Int { levels.count }
}

/// Observable façade over `WickedDevilCore.User`.
///
/// `User` is a plain reference type with no change notification, so every
/// mutation the menus perform goes through this type, which then re-derives the
/// snapshot values SwiftUI observes. All economy and progression *rules* stay
/// in `User` — this class only mirrors, never reimplements.
@Observable
final class MenuModel {
    @ObservationIgnored let user: User
    @ObservationIgnored let inventory: LevelInventory
    /// The same store `user` writes through. Needed for the handful of keys
    /// `User` persists but does not expose as a property (currently `muted`).
    @ObservationIgnored private let store: UserDataStore

    // Mirrored scalars. Stored (not computed) so `@Observable` tracks them.
    private(set) var souls: Int = 0
    private(set) var worldProgress: Int = 1
    private(set) var levelProgress: Int = 1
    private(set) var unlockedDetective = false
    private(set) var equippedPowerupSlot: Int = 0
    private(set) var hasEquippedPowerup = false
    private(set) var equippedCharacterIndex: Int = 0
    private(set) var hasEquippedCharacter = false
    private(set) var deaths: Int = 0
    private(set) var jumps: Int = 0
    private(set) var isMuted = false

    // Derived snapshots.
    private(set) var worlds: [WorldSummary] = []
    private(set) var detective: WorldSummary?
    private(set) var bonusLevel: LevelSummary?
    private(set) var ownedPowerups: Set<Int> = []
    private(set) var ownedSpecialPowerups: Set<Int> = []
    private(set) var ownedCharacters: Set<Int> = []
    private(set) var unlockedAchievements: Set<Achievement> = []

    /// Achievements unlocked by the most recent run, for the game-over screen.
    private(set) var lastRunAchievements: [Achievement] = []

    init(store: UserDataStore = UserDefaultsUserDataStore(), inventory: LevelInventory = .bundled) {
        self.store = store
        self.user = User(store: store)
        self.inventory = inventory
        refresh()
    }

    // MARK: - Snapshotting

    /// Re-reads everything from `User`. Called after any mutation.
    func refresh() {
        souls = user.collected
        worldProgress = user.worldProgress
        levelProgress = user.levelProgress
        unlockedDetective = user.unlockedDetective
        equippedPowerupSlot = user.powerup
        hasEquippedPowerup = user.boughtPowerups
        equippedCharacterIndex = user.character
        hasEquippedCharacter = user.boughtCharacter
        deaths = user.deaths
        jumps = user.jumps
        isMuted = store.bool(forKey: User.Key.muted)
        // The saved preference is the source of truth; push it to the audio
        // layer so gameplay honours the menus' mute toggle too.
        AudioEngine.shared.isMuted = isMuted

        ownedPowerups = Set(MenuCatalog.powerups.map(\.index).filter(user.ownsItem))
        ownedSpecialPowerups = Set(MenuCatalog.specialPowerups.map(\.index).filter(user.ownsSpecialItem))
        ownedCharacters = Set(MenuCatalog.characters.map(\.index).filter(user.ownsCharacter))
        unlockedAchievements = Set(Achievement.allCases.filter(user.hasAchievement))

        worlds = inventory.adventureWorlds.map(makeWorldSummary)
        detective = inventory.detectiveLevelCount > 0
            ? makeWorldSummary(world: GameConstants.detectiveWorld)
            : nil
        bonusLevel = inventory.hasBonusLevel
            ? makeLevelSummary(world: GameConstants.bonusWorld, level: GameConstants.bonusLevel)
            : nil
    }

    private func makeWorldSummary(world: Int) -> WorldSummary {
        let levels = inventory.levels(world: world).map { makeLevelSummary(world: world, level: $0) }
        return WorldSummary(
            world: world,
            theme: .theme(for: world),
            isUnlocked: isWorldUnlocked(world),
            levels: levels,
            soulsEarned: user.souls(world: world),
            soulsAvailable: inventory.soulsAvailable(world: world),
            halosEarned: world == GameConstants.detectiveWorld ? 0 : user.halos(world: world),
            halosAvailable: world == GameConstants.detectiveWorld ? 0 : inventory.halosAvailable(world: world),
            highScore: user.highscore(world: world)
        )
    }

    private func makeLevelSummary(world: Int, level: Int) -> LevelSummary {
        LevelSummary(
            world: world,
            level: level,
            isUnlocked: isLevelUnlocked(world: world, level: level),
            soulsEarned: user.souls(world: world, level: level),
            halosEarned: world == GameConstants.detectiveWorld ? 0 : user.halos(world: world, level: level),
            highScore: user.highscore(world: world, level: level)
        )
    }

    // MARK: - Unlock rules
    //
    // `WorldSelectScene.m`: a world button is enabled when
    // `user.worldprogress >= tag && tag <= CURRENT_WORLDS_PER_GAME`.

    func isWorldUnlocked(_ world: Int) -> Bool {
        switch world {
        case GameConstants.detectiveWorld: return user.unlockedDetective
        case GameConstants.bonusWorld: return true
        default:
            return user.worldProgress >= world && world <= GameConstants.currentWorldsPerGame
        }
    }

    /// The detective campaign gates at the world level only — once bought,
    /// `DetectiveLevelSelectScene.m` enabled every level unconditionally.
    func isLevelUnlocked(world: Int, level: Int) -> Bool {
        switch world {
        case GameConstants.detectiveWorld: return user.unlockedDetective
        case GameConstants.bonusWorld: return true
        default: return user.isLevelUnlocked(world: world, level: level)
        }
    }

    // MARK: - Totals for the stats/HUD readouts

    var totalAdventureSouls: Int { user.soulsForAllWorlds() }
    var totalAdventureSoulsAvailable: Int { inventory.totalAdventureSouls }
    var totalHalos: Int { user.halosForAllWorlds() }
    var totalHalosAvailable: Int { inventory.totalAdventureHalos }

    /// `StatsScene.m` "Total Score" — the sum of every shipped world's score.
    var totalScore: Int {
        inventory.adventureWorlds.reduce(0) { $0 + user.highscore(world: $1) }
    }

    // MARK: - Launching

    /// Builds the hand-off payload for a level, seeding the HUD's past score.
    func launchRequest(world: Int, level: Int, isRestart: Bool = false) -> GameLaunchRequest {
        GameLaunchRequest(
            world: world,
            level: level,
            isRestart: isRestart,
            pastScore: user.highscore(world: world, level: level)
        )
    }

    /// The level a "Next" button should go to, or `nil` when the player has
    /// reached the end of the shipped content.
    ///
    /// `GameOverScene.m` hid Next past `CURRENT_WORLDS_PER_GAME` and on the
    /// bonus level.
    func nextLevel(after request: GameLaunchRequest) -> GameLaunchRequest? {
        if request.isBonusLevel { return nil }

        let nextLevel = request.level + 1
        if inventory.hasLevel(world: request.world, level: nextLevel) {
            return launchRequest(world: request.world, level: nextLevel)
        }

        guard !request.isDetectiveLevel else { return nil }
        let nextWorld = request.world + 1
        guard nextWorld <= GameConstants.currentWorldsPerGame,
              inventory.hasLevel(world: nextWorld, level: 1) else { return nil }
        return launchRequest(world: nextWorld, level: 1)
    }

    // MARK: - Recording a finished run

    /// Banks a win: souls, high score, halos, progression and achievements, all
    /// through `User.recordCompletedLevel(_:)`.
    ///
    /// Losses are deliberately *not* recorded — `GameLayer.m end:` only pushed
    /// `GameOverScene` when `game.didWin`, and a death simply restarted the
    /// level. `User.deaths`/`jumps` are already updated by
    /// `Game.checkGameOver()` inside the gameplay layer.
    @discardableResult
    func record(_ result: GameResult) -> [Achievement] {
        guard result.didWin else {
            refresh()
            lastRunAchievements = []
            return []
        }
        let unlocked = user.recordCompletedLevel(result)
        lastRunAchievements = unlocked
        refresh()
        return unlocked
    }

    /// Whether the run beat the level's previous best, for the "NEW HIGHSCORE"
    /// banner. Must be read *before* `record(_:)` banks the score.
    func isNewHighScore(_ result: GameResult, pastScore: Int) -> Bool {
        result.didWin && result.finalScore > pastScore
    }

    // MARK: - Economy (all rules live in `User`)

    enum PurchaseOutcome: Equatable {
        case bought
        case alreadyOwned
        case notEnoughSouls(shortfall: Int)
        case unavailable
    }

    func canAfford(_ cost: Int) -> Bool { user.collected >= cost }

    /// `EquipScene.m tap_purchase:` — buy a devil upgrade.
    @discardableResult
    func buyPowerup(_ item: CatalogItem) -> PurchaseOutcome {
        guard !ownedPowerups.contains(item.index) else { return .alreadyOwned }
        guard user.spendSouls(item.cost) else {
            return .notEnoughSouls(shortfall: item.cost - user.collected)
        }
        user.buyItem(item.index)
        user.sync()
        refresh()
        return .bought
    }

    /// `EquipSpecialScene.m tap_purchase:` — buy a special upgrade.
    @discardableResult
    func buySpecialPowerup(_ item: CatalogItem) -> PurchaseOutcome {
        guard !ownedSpecialPowerups.contains(item.index) else { return .alreadyOwned }
        guard user.spendSouls(item.cost) else {
            return .notEnoughSouls(shortfall: item.cost - user.collected)
        }
        user.buySpecialItem(item.index)
        user.sync()
        refresh()
        return .bought
    }

    /// `CharacterShopScene.m tap_purchase:` — buy a character skin.
    @discardableResult
    func buyCharacter(_ item: CatalogItem) -> PurchaseOutcome {
        guard !ownedCharacters.contains(item.index) else { return .alreadyOwned }
        guard user.spendSouls(item.cost) else {
            return .notEnoughSouls(shortfall: item.cost - user.collected)
        }
        user.buyCharacter(item.index)
        user.sync()
        refresh()
        return .bought
    }

    // MARK: - Equipping
    //
    // The original stored one equipped upgrade in `User.powerup`: a devil
    // upgrade as its own index, a special upgrade as `index + 100`.

    func isPowerupEquipped(_ item: CatalogItem) -> Bool {
        hasEquippedPowerup && equippedPowerupSlot == item.index
    }

    func isSpecialPowerupEquipped(_ item: CatalogItem) -> Bool {
        hasEquippedPowerup && equippedPowerupSlot == item.index + MenuCatalog.specialPowerupOffset
    }

    func isCharacterEquipped(_ item: CatalogItem) -> Bool {
        hasEquippedCharacter && equippedCharacterIndex == item.index
    }

    func equipPowerup(_ item: CatalogItem) {
        guard ownedPowerups.contains(item.index) else { return }
        user.powerup = item.index
        user.boughtPowerups = true
        user.sync()
        refresh()
    }

    func equipSpecialPowerup(_ item: CatalogItem) {
        guard ownedSpecialPowerups.contains(item.index) else { return }
        user.powerup = item.index + MenuCatalog.specialPowerupOffset
        user.boughtPowerups = true
        user.sync()
        refresh()
    }

    func equipCharacter(_ item: CatalogItem) {
        guard ownedCharacters.contains(item.index) else { return }
        user.character = item.index
        user.boughtCharacter = true
        user.sync()
        refresh()
    }

    /// `btn-unequip-all.png`.
    func unequipPowerups() {
        user.powerup = 0
        user.boughtPowerups = false
        user.sync()
        refresh()
    }

    func unequipCharacter() {
        user.character = 0
        user.boughtCharacter = false
        user.sync()
        refresh()
    }

    /// The name of whatever is currently equipped, for the store hub.
    var equippedUpgradeName: String? {
        guard hasEquippedPowerup else { return nil }
        if equippedPowerupSlot >= MenuCatalog.specialPowerupOffset {
            let index = equippedPowerupSlot - MenuCatalog.specialPowerupOffset
            return MenuCatalog.specialPowerups.first { $0.index == index }?.name
        }
        return MenuCatalog.powerups.first { $0.index == equippedPowerupSlot }?.name
    }

    var equippedCharacterName: String? {
        guard hasEquippedCharacter else { return nil }
        return MenuCatalog.characters.first { $0.index == equippedCharacterIndex }?.name
    }

    // MARK: - Soul-gated unlocks

    var detectiveUnlockCost: Int { GameConstants.detectiveUnlockCost }
    var skipCost: Int { GameConstants.skipCost }

    /// `AdventureSelectScene.m tap_unlock_detective`.
    @discardableResult
    func unlockDetective() -> PurchaseOutcome {
        guard !user.unlockedDetective else { return .alreadyOwned }
        guard user.unlockDetective() else {
            return .notEnoughSouls(shortfall: GameConstants.detectiveUnlockCost - user.collected)
        }
        refresh()
        return .bought
    }

    /// `LevelSelectScene.m tap_skip` — the skip button was only offered while
    /// the player was still working through the world.
    func canSkip(world: Int) -> Bool {
        user.canSkipLevel && !(user.worldProgress > world) && world <= GameConstants.currentWorldsPerGame
    }

    @discardableResult
    func buyLevelSkip() -> PurchaseOutcome {
        guard user.canSkipLevel else { return .unavailable }
        guard user.buyLevelSkip() else {
            return .notEnoughSouls(shortfall: GameConstants.skipCost - user.collected)
        }
        refresh()
        return .bought
    }

    // MARK: - Misc

    /// `GameOverScene.m` nudged the player towards the upgrade store the first
    /// time they could afford something, then set `TIP-POWERUP-SEEN` so the
    /// prompt never appeared again.
    private static let powerupTipKey = "TIP-POWERUP-SEEN"

    var shouldShowUpgradeTip: Bool {
        souls >= 2000 && !store.bool(forKey: Self.powerupTipKey)
    }

    func markUpgradeTipSeen() {
        store.set(true, forKey: Self.powerupTipKey)
        store.synchronize()
    }

    func toggleMute() {
        store.set(!store.bool(forKey: User.Key.muted), forKey: User.Key.muted)
        store.synchronize()
        refresh()
    }

    /// Wipes the profile. Exposed on the stats screen behind a confirmation.
    func resetProfile() {
        user.reset()
        refresh()
    }

    func unlockEverything() {
        user.unlockEverything()
        refresh()
    }
}

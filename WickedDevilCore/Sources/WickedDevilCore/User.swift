import Foundation

/// Persistent player profile: progress, souls economy, unlocks and achievements.
///
/// Ported from `Objects/User.m`. The Parse, Facebook, Flurry and iRate
/// integrations are deliberately **not** ported — only the local logic remains.
/// Reachability (`isOnline`) is dropped for the same reason.
public final class User {
    /// `NSUserDefaults` key names, kept identical so an existing install's data
    /// still reads correctly.
    public enum Key {
        public static let created = "created"
        public static let highscores = "highscores"
        public static let souls = "souls"
        public static let halos = "halos"
        public static let detectiveHighscores = "detective_highscores"
        public static let detectiveSouls = "detective_souls"
        public static let gameProgress = "gameprogress"
        public static let items = "items"
        public static let itemsSpecial = "items_special"
        public static let itemsCharacters = "items_characters"
        public static let levelProgress = "levelprogress"
        public static let worldProgress = "worldprogress"
        public static let powerup = "powerup"
        public static let character = "character"
        public static let collected = "collected"
        public static let deaths = "deaths"
        public static let jumps = "jumps"
        public static let boughtPowerups = "bought_powerups"
        public static let boughtCharacter = "bought_character"
        public static let cacheCurrentWorld = "cache_current_world"
        public static let unlockedDetective = "unlocked_detective"
        public static let muted = "muted"
    }

    /// Number of buyable standard powerups. The original read this from
    /// `Powerups.plist`; the count is fixed at build time so it is a constant
    /// here (the plist is a rendering/catalogue concern).
    public static let powerupSlotCount = 100
    public static let specialItemSlotCount = 100
    public static let characterSlotCount = 100

    private let store: UserDataStore

    // MARK: - Scalar state (mirrors the ObjC properties)

    public var collected: Int
    public var levelProgress: Int
    public var worldProgress: Int
    public var powerup: Int
    public var character: Int
    public var cacheCurrentWorld: Int
    public var deaths: Int
    public var jumps: Int
    public var boughtPowerups: Bool
    public var boughtCharacter: Bool
    public var unlockedDetective: Bool

    // MARK: - Array state

    public private(set) var highscores: [[Int]]
    public private(set) var souls: [[Int]]
    public private(set) var halos: [[Int]]
    public private(set) var detectiveHighscores: [[Int]]
    public private(set) var detectiveSouls: [[Int]]
    public private(set) var gameProgress: [[Int]]
    public private(set) var items: [Int]
    public private(set) var itemsSpecial: [Int]
    public private(set) var itemsCharacters: [Int]

    /// Achievements that have been earned locally.
    public private(set) var unlockedAchievements: Set<Achievement>

    // MARK: - Init

    public init(store: UserDataStore) {
        self.store = store

        if !store.bool(forKey: Key.created) {
            User.create(in: store)
        }
        if !store.hasValue(forKey: Key.itemsSpecial) {
            User.createSpecialItems(in: store)
        }
        if !store.hasValue(forKey: Key.detectiveHighscores) {
            User.createDetectiveSettings(in: store)
        }
        if !store.hasValue(forKey: Key.halos) {
            User.createHaloSettings(in: store)
        }
        if !store.hasValue(forKey: Key.unlockedDetective) {
            store.set(false, forKey: Key.unlockedDetective)
            store.synchronize()
        }
        if !store.hasValue(forKey: Key.itemsCharacters) {
            User.createCharacterItems(in: store)
        }

        highscores = store.intMatrix(forKey: Key.highscores) ?? User.emptyWorldMatrix()
        souls = store.intMatrix(forKey: Key.souls) ?? User.emptyWorldMatrix()
        halos = store.intMatrix(forKey: Key.halos) ?? User.emptyWorldMatrix()
        detectiveHighscores = store.intMatrix(forKey: Key.detectiveHighscores) ?? User.emptyDetectiveMatrix()
        detectiveSouls = store.intMatrix(forKey: Key.detectiveSouls) ?? User.emptyDetectiveMatrix()
        gameProgress = store.intMatrix(forKey: Key.gameProgress) ?? User.freshGameProgress()
        items = store.intArray(forKey: Key.items) ?? Array(repeating: 0, count: User.powerupSlotCount)
        itemsSpecial = store.intArray(forKey: Key.itemsSpecial) ?? Array(repeating: 0, count: User.specialItemSlotCount)
        itemsCharacters = store.intArray(forKey: Key.itemsCharacters) ?? Array(repeating: 0, count: User.characterSlotCount)

        levelProgress = store.integer(forKey: Key.levelProgress)
        worldProgress = store.integer(forKey: Key.worldProgress)
        powerup = store.integer(forKey: Key.powerup)
        character = store.integer(forKey: Key.character)
        cacheCurrentWorld = store.integer(forKey: Key.cacheCurrentWorld)
        collected = store.integer(forKey: Key.collected)
        deaths = store.integer(forKey: Key.deaths)
        jumps = store.integer(forKey: Key.jumps)
        boughtPowerups = store.bool(forKey: Key.boughtPowerups)
        boughtCharacter = store.bool(forKey: Key.boughtCharacter)
        unlockedDetective = store.bool(forKey: Key.unlockedDetective)

        unlockedAchievements = Set(Achievement.allCases.filter { store.bool(forKey: $0.storageKey) })
    }

    // MARK: - Creation (`create`, `create_*`)

    static func emptyWorldMatrix() -> [[Int]] {
        Array(
            repeating: Array(repeating: 0, count: GameConstants.levelsPerWorld),
            count: GameConstants.worldsPerGame
        )
    }

    static func emptyDetectiveMatrix() -> [[Int]] {
        [Array(repeating: 0, count: GameConstants.detectiveLevelCount)]
    }

    static func freshGameProgress() -> [[Int]] {
        var progress = emptyWorldMatrix()
        progress[0][0] = 1
        return progress
    }

    private static func create(in store: UserDataStore) {
        store.set(Array(repeating: 0, count: powerupSlotCount), forKey: Key.items)
        store.set(emptyWorldMatrix(), forKey: Key.highscores)
        store.set(emptyWorldMatrix(), forKey: Key.souls)
        store.set(1, forKey: Key.levelProgress)
        store.set(1, forKey: Key.worldProgress)
        store.set(freshGameProgress(), forKey: Key.gameProgress)
        store.set(0, forKey: Key.powerup)
        store.set(1, forKey: Key.cacheCurrentWorld)
        store.set(0, forKey: Key.collected)
        store.set(0, forKey: Key.deaths)
        store.set(0, forKey: Key.jumps)
        store.set(false, forKey: Key.muted)
        store.set(false, forKey: Key.unlockedDetective)
        store.set(true, forKey: Key.created)
        store.synchronize()
    }

    private static func createSpecialItems(in store: UserDataStore) {
        store.set(Array(repeating: 0, count: specialItemSlotCount), forKey: Key.itemsSpecial)
        store.synchronize()
    }

    private static func createCharacterItems(in store: UserDataStore) {
        store.set(Array(repeating: 0, count: characterSlotCount), forKey: Key.itemsCharacters)
        store.set(0, forKey: Key.character)
        store.synchronize()
    }

    private static func createDetectiveSettings(in store: UserDataStore) {
        store.set(emptyDetectiveMatrix(), forKey: Key.detectiveHighscores)
        store.set(emptyDetectiveMatrix(), forKey: Key.detectiveSouls)
        store.synchronize()
    }

    private static func createHaloSettings(in store: UserDataStore) {
        store.set(emptyWorldMatrix(), forKey: Key.halos)
        store.synchronize()
    }

    // MARK: - Persistence (`sync`, `reset`)

    /// `User sync` — writes back every scalar property.
    public func sync() {
        store.set(levelProgress, forKey: Key.levelProgress)
        store.set(worldProgress, forKey: Key.worldProgress)
        store.set(deaths, forKey: Key.deaths)
        store.set(jumps, forKey: Key.jumps)
        store.set(collected, forKey: Key.collected)
        store.set(powerup, forKey: Key.powerup)
        store.set(character, forKey: Key.character)
        store.set(boughtPowerups, forKey: Key.boughtPowerups)
        store.set(boughtCharacter, forKey: Key.boughtCharacter)
        store.set(unlockedDetective, forKey: Key.unlockedDetective)
        store.synchronize()
    }

    /// `User sync_cache_current_world`
    public func syncCacheCurrentWorld() {
        store.set(cacheCurrentWorld, forKey: Key.cacheCurrentWorld)
        store.synchronize()
    }

    /// `User sync_achievements`
    public func syncAchievements() {
        for achievement in Achievement.allCases {
            store.set(unlockedAchievements.contains(achievement), forKey: achievement.storageKey)
        }
        store.synchronize()
    }

    /// `User reset` — wipes achievements and recreates a fresh profile.
    public func reset() {
        store.set(false, forKey: Key.created)
        for achievement in Achievement.allCases {
            store.set(false, forKey: achievement.storageKey)
            store.set(false, forKey: achievement.sentStorageKey)
        }
        unlockedAchievements.removeAll()
        User.create(in: store)

        highscores = User.emptyWorldMatrix()
        souls = User.emptyWorldMatrix()
        gameProgress = User.freshGameProgress()
        items = Array(repeating: 0, count: User.powerupSlotCount)
        levelProgress = 1
        worldProgress = 1
        powerup = 0
        cacheCurrentWorld = 1
        collected = 0
        deaths = 0
        jumps = 0
        boughtPowerups = false
        boughtCharacter = false
        unlockedDetective = false
        store.synchronize()
    }

    // MARK: - Purchases

    /// `User buyItem:`
    public func buyItem(_ index: Int) {
        guard items.indices.contains(index) else { return }
        items[index] = 1
        store.set(items, forKey: Key.items)
        store.synchronize()
    }

    /// `User buySpecialItem:`
    public func buySpecialItem(_ index: Int) {
        guard itemsSpecial.indices.contains(index) else { return }
        itemsSpecial[index] = 1
        store.set(itemsSpecial, forKey: Key.itemsSpecial)
        store.synchronize()
    }

    /// `User buyCharacter:`
    public func buyCharacter(_ index: Int) {
        guard itemsCharacters.indices.contains(index) else { return }
        itemsCharacters[index] = 1
        store.set(itemsCharacters, forKey: Key.itemsCharacters)
        store.synchronize()
    }

    public func ownsItem(_ index: Int) -> Bool {
        items.indices.contains(index) && items[index] == 1
    }

    public func ownsSpecialItem(_ index: Int) -> Bool {
        itemsSpecial.indices.contains(index) && itemsSpecial[index] == 1
    }

    public func ownsCharacter(_ index: Int) -> Bool {
        itemsCharacters.indices.contains(index) && itemsCharacters[index] == 1
    }

    /// Spends souls if the player can afford it.
    /// - Returns: `true` when the purchase went through.
    @discardableResult
    public func spendSouls(_ cost: Int) -> Bool {
        guard collected >= cost else { return false }
        collected -= cost
        return true
    }

    /// `ShopLayer` detective purchase: costs `DETECTIVE_UNLOCK_COST` souls.
    @discardableResult
    public func unlockDetective() -> Bool {
        guard !unlockedDetective else { return false }
        guard spendSouls(GameConstants.detectiveUnlockCost) else { return false }
        unlockedDetective = true
        sync()
        return true
    }

    /// Buys and applies a level skip: costs `SKIP_COST` souls.
    @discardableResult
    public func buyLevelSkip() -> Bool {
        guard collected >= GameConstants.skipCost else { return false }
        guard canSkipLevel else { return false }
        collected -= GameConstants.skipCost
        skipLevel()
        return true
    }

    /// `User skipLevel` only advances while there is a world left to unlock.
    public var canSkipLevel: Bool {
        worldProgress != GameConstants.currentWorldsPerGame + 1
    }

    /// `User skipLevel`
    public func skipLevel() {
        guard canSkipLevel else { return }

        let nextWorld: Int
        let nextLevel: Int
        if levelProgress == GameConstants.levelsPerWorld {
            nextLevel = 1
            nextWorld = worldProgress + 1
        } else {
            nextLevel = levelProgress + 1
            nextWorld = worldProgress
        }

        worldProgress = nextWorld
        levelProgress = nextLevel
        setGameProgress(world: worldProgress, level: levelProgress)
        sync()
    }

    // MARK: - Setters

    /// `User setGameProgressforWorld:level:`
    public func setGameProgress(world: Int, level: Int) {
        guard gameProgress.indices.contains(world - 1),
              gameProgress[world - 1].indices.contains(level - 1) else { return }
        gameProgress[world - 1][level - 1] = 1
        store.set(gameProgress, forKey: Key.gameProgress)
        store.synchronize()
    }

    /// `User setHighscore:world:level:` — only writes when the score improves.
    public func setHighscore(_ score: Int, world: Int, level: Int) {
        guard score > highscore(world: world, level: level) else { return }
        if world == GameConstants.detectiveWorld {
            guard detectiveHighscores.indices.contains(0),
                  detectiveHighscores[0].indices.contains(level - 1) else { return }
            detectiveHighscores[0][level - 1] = score
            store.set(detectiveHighscores, forKey: Key.detectiveHighscores)
        } else {
            guard highscores.indices.contains(world - 1),
                  highscores[world - 1].indices.contains(level - 1) else { return }
            highscores[world - 1][level - 1] = score
            store.set(highscores, forKey: Key.highscores)
        }
        store.synchronize()
    }

    /// `User setSouls:world:level:` — only writes when the soul count improves.
    public func setSouls(_ value: Int, world: Int, level: Int) {
        guard value > souls(world: world, level: level) else { return }
        if world == GameConstants.detectiveWorld {
            guard detectiveSouls.indices.contains(0),
                  detectiveSouls[0].indices.contains(level - 1) else { return }
            detectiveSouls[0][level - 1] = value
            store.set(detectiveSouls, forKey: Key.detectiveSouls)
        } else {
            guard souls.indices.contains(world - 1),
                  souls[world - 1].indices.contains(level - 1) else { return }
            souls[world - 1][level - 1] = value
            store.set(souls, forKey: Key.souls)
        }
        store.synchronize()
    }

    /// `User setHalos:world:level:` — only writes when the halo count improves.
    public func setHalos(_ value: Int, world: Int, level: Int) {
        guard value > halos(world: world, level: level) else { return }
        guard halos.indices.contains(world - 1),
              halos[world - 1].indices.contains(level - 1) else { return }
        halos[world - 1][level - 1] = value
        store.set(halos, forKey: Key.halos)
        store.synchronize()
    }

    // MARK: - Getters

    private func row(_ matrix: [[Int]], _ index: Int) -> [Int] {
        matrix.indices.contains(index) ? matrix[index] : []
    }

    private func value(_ matrix: [[Int]], world: Int, level: Int) -> Int {
        let r = row(matrix, world - 1)
        guard r.indices.contains(level - 1) else { return 0 }
        return r[level - 1]
    }

    /// `User getHighscoreforWorld:level:`
    public func highscore(world: Int, level: Int) -> Int {
        world == GameConstants.detectiveWorld
            ? value(detectiveHighscores, world: 1, level: level)
            : value(highscores, world: world, level: level)
    }

    /// `User getHighscoreforWorld:` — total score across a world.
    public func highscore(world: Int) -> Int {
        world == GameConstants.detectiveWorld
            ? row(detectiveHighscores, 0).reduce(0, +)
            : row(highscores, world - 1).reduce(0, +)
    }

    /// `User getSoulsforWorld:level:`
    public func souls(world: Int, level: Int) -> Int {
        world == GameConstants.detectiveWorld
            ? value(detectiveSouls, world: 1, level: level)
            : value(souls, world: world, level: level)
    }

    /// `User getSoulsforWorld:` — total souls across a world.
    public func souls(world: Int) -> Int {
        world == GameConstants.detectiveWorld
            ? row(detectiveSouls, 0).reduce(0, +)
            : row(souls, world - 1).reduce(0, +)
    }

    /// `User getSoulsforAll` — total souls across the shipped worlds.
    public func soulsForAllWorlds() -> Int {
        (1...GameConstants.currentWorldsPerGame).reduce(0) { total, world in
            total + (1...GameConstants.levelsPerWorld).reduce(0) { $0 + souls(world: world, level: $1) }
        }
    }

    /// `User getHalosforWorld:level:`
    public func halos(world: Int, level: Int) -> Int {
        value(halos, world: world, level: level)
    }

    /// `User getHalosforWorld:` — total halos across a world.
    ///
    /// - Note: the original indexed `[tmp objectAtIndex:0]` regardless of `w`,
    ///   so every world reported world 1's halos. Fixed here to use `w - 1`.
    public func halos(world: Int) -> Int {
        row(halos, world - 1).reduce(0, +)
    }

    /// `User getHalosforAll` — total halos across the shipped worlds.
    public func halosForAllWorlds() -> Int {
        (1...GameConstants.currentWorldsPerGame).reduce(0) { total, world in
            total + (1...GameConstants.levelsPerWorld).reduce(0) { $0 + halos(world: world, level: $1) }
        }
    }

    /// `User getGameProgressforWorld:level:` — 1 when the level is unlocked.
    public func gameProgress(world: Int, level: Int) -> Int {
        value(gameProgress, world: world, level: level) == 1 ? 1 : 0
    }

    public func isLevelUnlocked(world: Int, level: Int) -> Bool {
        gameProgress(world: world, level: level) == 1
    }

    // MARK: - Level completion (`GameOverScene`)

    /// Applies a finished run to the profile: banks souls, records the score
    /// and advances progression when the run was on the newest level.
    ///
    /// Ported from `GameOverScene initWithGame:`.
    /// - Returns: the achievements unlocked by this run.
    @discardableResult
    public func recordCompletedLevel(_ result: GameResult) -> [Achievement] {
        collected += result.collected

        setHighscore(result.finalScore, world: result.world, level: result.level)
        setSouls(result.bigCollected, world: result.world, level: result.level)
        if result.world != GameConstants.detectiveWorld {
            setHalos(result.haloCollected, world: result.world, level: result.level)
        }

        if result.world == worldProgress && result.level == levelProgress {
            if levelProgress == GameConstants.levelsPerWorld {
                levelProgress = 1
                worldProgress += 1
            } else {
                levelProgress += 1
            }
            setGameProgress(world: worldProgress, level: levelProgress)
        }

        sync()
        cacheCurrentWorld = worldProgress
        syncCacheCurrentWorld()
        return checkAchievements()
    }

    // MARK: - Achievements

    /// `User check_achiements` — evaluates every threshold and persists the
    /// results.
    /// - Returns: achievements newly unlocked by this call.
    @discardableResult
    public func checkAchievements() -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        func unlock(_ achievement: Achievement, when condition: Bool) {
            guard condition, !unlockedAchievements.contains(achievement) else { return }
            unlockedAchievements.insert(achievement)
            newlyUnlocked.append(achievement)
        }

        unlock(.firstPlay, when: true)
        unlock(.collected666Souls, when: collected >= GameConstants.Threshold.souls666)
        unlock(.thousandSouls, when: collected >= GameConstants.Threshold.souls1000)
        unlock(.fiveThousandSouls, when: collected >= GameConstants.Threshold.souls5000)
        unlock(.tenThousandSouls, when: collected >= GameConstants.Threshold.souls10000)
        unlock(.fiftyThousandSouls, when: collected >= GameConstants.Threshold.souls50000)
        unlock(.beatWorld1, when: worldProgress > 1)
        unlock(.beatWorld2, when: worldProgress > 2)
        unlock(.beatWorld3, when: worldProgress > 3)
        unlock(
            .beatWorld4,
            when: worldProgress >= 4 && levelProgress >= GameConstants.levelsPerWorld
        )
        unlock(.killed, when: deaths >= GameConstants.Threshold.deathsKilled)
        unlock(.died100, when: deaths >= GameConstants.Threshold.deaths100)
        unlock(.jumped1000, when: jumps >= GameConstants.Threshold.jumps1000)
        // The original tested `== 80`, which silently failed if the total ever
        // exceeded 80. Widened to `>=`.
        unlock(.halo, when: halosForAllWorlds() >= GameConstants.Threshold.halosAll)

        syncAchievements()
        return newlyUnlocked
    }

    public func hasAchievement(_ achievement: Achievement) -> Bool {
        unlockedAchievements.contains(achievement)
    }

    /// Whether the achievement has been reported to Game Center. Kept so the
    /// app layer can drive submission; nothing in this package sets it.
    public func hasSentAchievement(_ achievement: Achievement) -> Bool {
        store.bool(forKey: achievement.sentStorageKey)
    }

    public func markAchievementSent(_ achievement: Achievement) {
        store.set(true, forKey: achievement.sentStorageKey)
        store.synchronize()
    }
}

/// The local achievements from `User.m`, with their Game Center IDs and the
/// `NSUserDefaults` keys the original persisted them under.
public enum Achievement: String, CaseIterable, Hashable, Sendable {
    case firstPlay = "ach_first_play"
    case collected666Souls = "ach_collected_666"
    case thousandSouls = "ach_1000_souls"
    case fiveThousandSouls = "ach_5000_souls"
    case tenThousandSouls = "ach_10000_souls"
    case fiftyThousandSouls = "ach_50000_souls"
    case beatWorld1 = "ach_beat_world_1"
    case beatWorld2 = "ach_beat_world_2"
    case beatWorld3 = "ach_beat_world_3"
    case beatWorld4 = "ach_beat_world_4"
    case killed = "ach_killed"
    case died100 = "ach_died_100"
    case jumped1000 = "ach_jumped_1000"
    case halo = "ach_halo"

    public var storageKey: String { rawValue }
    public var sentStorageKey: String { "sent_" + rawValue }

    /// The Game Center achievement ID from `GameConstants.h`.
    public var gameCenterID: Int {
        switch self {
        case .firstPlay: return GameConstants.AchievementID.firstPlay
        case .collected666Souls: return GameConstants.AchievementID.collected666Souls
        case .thousandSouls: return GameConstants.AchievementID.thousandSouls
        case .fiveThousandSouls: return GameConstants.AchievementID.fiveThousandSouls
        case .tenThousandSouls: return GameConstants.AchievementID.tenThousandSouls
        case .fiftyThousandSouls: return GameConstants.AchievementID.fiftyThousandSouls
        case .beatWorld1: return GameConstants.AchievementID.beatWorld1
        case .beatWorld2: return GameConstants.AchievementID.beatWorld2
        case .beatWorld3: return GameConstants.AchievementID.beatWorld3
        case .beatWorld4: return GameConstants.AchievementID.beatWorld4
        case .killed: return GameConstants.AchievementID.killedByDeath
        case .died100: return GameConstants.AchievementID.died100Times
        case .jumped1000: return GameConstants.AchievementID.thousandJumpsOnPlatform
        case .halo: return GameConstants.AchievementID.halo
        }
    }
}

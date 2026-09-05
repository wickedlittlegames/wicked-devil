import Foundation

/// Game-wide constants ported from `Wicked Little Devil/Config/GameConstants.h`.
///
/// The original API tokens (`WDPHToken`, `WDPHSecret`, `WDPHGameID`) are
/// deliberately dropped: they belonged to the retired PlayHaven integration.
public enum GameConstants {

    // MARK: - Game centric numbers

    public static let levelsPerWorld = 20
    public static let worldsPerGame = 12
    /// Number of worlds actually shipped in v1.2.
    public static let currentWorldsPerGame = 4

    /// Soul cost to unlock the detective (world 20) adventure.
    public static let detectiveUnlockCost = 15_000
    /// Soul cost to skip the current level.
    public static let skipCost = 5_000

    /// The detective adventure is stored as a pseudo-world with this number and
    /// is persisted in separate arrays (`detective_highscores`/`detective_souls`).
    public static let detectiveWorld = 20
    /// The detective adventure only ever shipped 12 levels.
    public static let detectiveLevelCount = 12

    /// `world == 11 && level == 1` is the bonus level.
    public static let bonusWorld = 11
    public static let bonusLevel = 1

    // MARK: - Achievement identifiers (Game Center IDs from GameConstants.h)

    public enum AchievementID {
        public static let firstPlay = 1
        public static let beatWorld1 = 2
        public static let beatWorld2 = 3
        public static let beatWorld3 = 4
        public static let beatWorld4 = 21
        public static let killedByDeath = 8
        public static let thousandSouls = 9
        public static let fiveThousandSouls = 10
        public static let tenThousandSouls = 11
        public static let fiftyThousandSouls = 12
        public static let died100Times = 13
        public static let thousandJumpsOnPlatform = 14
        public static let collected666Souls = 20
        public static let halo = 22
    }

    // MARK: - Achievement thresholds

    public enum Threshold {
        public static let souls666 = 666
        public static let souls1000 = 1_000
        public static let souls5000 = 5_000
        public static let souls10000 = 10_000
        public static let souls50000 = 50_000
        public static let deathsKilled = 1
        public static let deaths100 = 100
        public static let jumps1000 = 1_000
        /// `User.m` checked `[self getHalosforAll] == 80`; 80 is the total number
        /// of halos available across the four shipped worlds.
        public static let halosAll = 80
    }

    // MARK: - Scoring (GameOverScene.m)

    /// Each big collectable ("soul") is worth this much at level end.
    public static let pointsPerBigCollectable = 1_000
    /// Each unused second of the level time limit is worth this much.
    public static let pointsPerSecondRemaining = 100

    // MARK: - Level time limits (GameScene.m)

    public static let baseTimeLimitSeconds = 30
    public static let mediumTimeLimitSeconds = 60
    public static let longTimeLimitSeconds = 90
    public static let mediumTimeLimitTopBoundary = 2_500.0
    public static let longTimeLimitTopBoundary = 5_000.0

    /// `GameScene.m`: the level time limit is derived from the height of the
    /// level's top boundary trigger.
    public static func timeLimit(forTopBoundaryY top: Double) -> Int {
        if top > longTimeLimitTopBoundary { return longTimeLimitSeconds }
        if top > mediumTimeLimitTopBoundary { return mediumTimeLimitSeconds }
        return baseTimeLimitSeconds
    }

    // MARK: - Intro fly-over (GameScene.m)

    /// `float time_for_anim = top/400;` — the intro camera covers this many
    /// authored points per second, so tall levels get a proportionally longer
    /// establishing shot.
    public static let introPointsPerSecond = 400.0

    // MARK: - World culling thresholds (GameLayer.m)

    /// Nodes below this Y (in layer space) are despawned.
    public static let despawnY = -80.0
    /// Big/halo collectables are despawned lower down than everything else.
    public static let bigCollectableDespawnY = -200.0
    /// Nodes are only made visible above this Y.
    public static let visibilityFloorY = -20.0
    /// Enemies get a slightly more generous visibility floor.
    public static let enemyVisibilityFloorY = -70.0
    /// Player falls out of the world (game over) below this Y.
    public static let playerDeathY = -80.0
}

/// Device-dependent tuning. The original code branched on an `IS_IPHONE5`
/// macro; those branches are collapsed into this enum so the values stay
/// explicit and testable.
public enum DeviceProfile: String, Codable, Sendable, CaseIterable {
    /// 320x480 logical viewport (the default the `.ccbi` converter targets).
    case standard
    /// 320x568 logical viewport (`IS_IPHONE5`).
    case tall

    public var viewportSize: SizeF {
        switch self {
        case .standard: return SizeF(width: 320, height: 480)
        case .tall: return SizeF(width: 320, height: 568)
        }
    }

    /// `Player.m` init: `jumpspeed = 5.5` / `6.51` on iPhone 5.
    public var jumpSpeed: Double {
        switch self {
        case .standard: return 5.5
        case .tall: return 6.51
        }
    }

    /// `Player.m` init: `gravity = 0.18` / `0.21` on iPhone 5.
    public var gravity: Double {
        switch self {
        case .standard: return 0.18
        case .tall: return 0.21
        }
    }

    /// `Platform.m`/`Enemy.m` moving-node travel distance (100 / 118).
    public var moverTravel: Double {
        switch self {
        case .standard: return 100
        case .tall: return 118
        }
    }

    /// `Enemy.m action_bubble_float`: bubble lift distance (250 / 295).
    public var bubbleLift: Double {
        switch self {
        case .standard: return 250
        case .tall: return 295
        }
    }

    /// `Enemy.m action_shoot_rocket`: rocket travel speed (400 / 473).
    public var rocketSpeed: Double {
        switch self {
        case .standard: return 400
        case .tall: return 473
        }
    }
}

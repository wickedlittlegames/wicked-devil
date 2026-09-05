import Foundation

/// Per-run game state, ported from `Objects/Game.h`.
///
/// The original `Game` was a bag of properties shared between the scene layers.
/// It keeps that role here, minus the cocos2d FX layer reference.
public final class Game {
    public var world: Int
    public var level: Int
    /// The player's previous best score for this level, shown on the HUD.
    public var pastScore: Int
    /// Level time limit in whole seconds.
    public var timeLimit: Int

    public var isGameover: Bool
    public var didWin: Bool
    public var isStarted: Bool
    public var isIntro: Bool
    public var isRestart: Bool

    public var player: Player
    public var user: User?
    /// Current touch point the player drifts towards.
    public var touch: Vec2

    public init(
        world: Int,
        level: Int,
        player: Player,
        user: User? = nil,
        pastScore: Int = 0,
        timeLimit: Int = GameConstants.baseTimeLimitSeconds,
        isRestart: Bool = false
    ) {
        self.world = world
        self.level = level
        self.player = player
        self.user = user
        self.pastScore = pastScore
        self.timeLimit = timeLimit
        self.isGameover = false
        self.didWin = false
        self.isStarted = false
        self.isIntro = false
        self.isRestart = isRestart
        self.touch = player.position
    }

    /// `world == 11 && level == 1`
    public var isBonusLevel: Bool {
        world == GameConstants.bonusWorld && level == GameConstants.bonusLevel
    }

    /// The detective adventure stores its progress separately.
    public var isDetectiveLevel: Bool {
        world == GameConstants.detectiveWorld
    }

    /// `GameScene startGame` — kicks the run off with an initial jump.
    public func start() {
        isStarted = true
        isGameover = false
        isIntro = false
        player.controllable = true
        touch = player.position
        player.jump(player.jumpSpeed)
    }

    /// `GameScene countdown:` — called once a second while the run is live.
    public func tickClock() {
        player.time += 1
    }

    /// `GameLayer gameoverCheck:` — the run ends when the player dies or drops
    /// out of the bottom of the level.
    ///
    /// - Returns: a `.gameOver` event the first time the run ends.
    @discardableResult
    public func checkGameOver() -> GameEvent? {
        guard !isGameover else { return nil }

        if !player.isAlive {
            isGameover = true
        } else if player.position.y < GameConstants.playerDeathY {
            isGameover = true
        }

        guard isGameover else { return nil }

        if !player.isAlive {
            player.deaths += 1
            user?.deaths += 1
        }
        user?.jumps += player.jumps
        user?.sync()
        return .gameOver(didWin: didWin)
    }

    /// Level-end scoring, ported from `GameOverScene initWithGame:`.
    ///
    /// - Note: the time bonus is *not* clamped: running over the time limit
    ///   subtracts 100 points per second, exactly as the original did.
    public var result: GameResult {
        GameResult(
            world: world,
            level: level,
            bigCollected: player.bigCollected,
            collected: player.collected,
            haloCollected: player.haloCollected,
            timeLimit: timeLimit,
            timeTaken: player.time,
            pointsPerCollectable: player.perCollectable,
            didWin: didWin
        )
    }
}

/// The score breakdown for a finished run.
public struct GameResult: Equatable, Sendable {
    public let world: Int
    public let level: Int
    public let bigCollected: Int
    public let collected: Int
    public let haloCollected: Int
    public let timeLimit: Int
    public let timeTaken: Int
    public let pointsPerCollectable: Int
    public let didWin: Bool

    public init(
        world: Int,
        level: Int,
        bigCollected: Int,
        collected: Int,
        haloCollected: Int,
        timeLimit: Int,
        timeTaken: Int,
        pointsPerCollectable: Int,
        didWin: Bool
    ) {
        self.world = world
        self.level = level
        self.bigCollected = bigCollected
        self.collected = collected
        self.haloCollected = haloCollected
        self.timeLimit = timeLimit
        self.timeTaken = timeTaken
        self.pointsPerCollectable = pointsPerCollectable
        self.didWin = didWin
    }

    /// `souls_score = souls * 1000`
    public var soulsScore: Int {
        bigCollected * GameConstants.pointsPerBigCollectable
    }

    /// `timebonus = timelimit - time`
    public var timeBonus: Int { timeLimit - timeTaken }

    /// `timebonus_score = timebonus * 100`
    public var timeBonusScore: Int {
        timeBonus * GameConstants.pointsPerSecondRemaining
    }

    /// `collected * per_collectable`
    public var collectableScore: Int {
        collected * pointsPerCollectable
    }

    /// `final_score = (souls_score + timebonus_score) + (collected * per_collectable)`
    public var finalScore: Int {
        soulsScore + timeBonusScore + collectableScore
    }
}

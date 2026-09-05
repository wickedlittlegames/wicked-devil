import XCTest
@testable import WickedDevilCore

final class UserTests: XCTestCase {

    private var store: InMemoryUserDataStore!
    private var user: User!

    override func setUp() {
        super.setUp()
        store = InMemoryUserDataStore()
        user = User(store: store)
    }

    // MARK: - Creation

    func testFreshProfileStartsOnWorldOneLevelOne() {
        XCTAssertEqual(user.worldProgress, 1)
        XCTAssertEqual(user.levelProgress, 1)
        XCTAssertEqual(user.collected, 0)
        XCTAssertFalse(user.unlockedDetective)
        XCTAssertTrue(user.isLevelUnlocked(world: 1, level: 1))
        XCTAssertFalse(user.isLevelUnlocked(world: 1, level: 2))
    }

    func testMatricesAreSizedFromGameConstants() {
        XCTAssertEqual(user.highscores.count, GameConstants.worldsPerGame)
        XCTAssertEqual(user.highscores[0].count, GameConstants.levelsPerWorld)
        XCTAssertEqual(user.halos.count, GameConstants.worldsPerGame)
        XCTAssertEqual(user.detectiveSouls.count, 1)
        XCTAssertEqual(user.detectiveSouls[0].count, GameConstants.detectiveLevelCount)
    }

    // MARK: - Persistence round trips

    func testScalarStateRoundTripsThroughTheStore() {
        user.collected = 4_321
        user.deaths = 7
        user.jumps = 812
        user.powerup = 20
        user.worldProgress = 2
        user.levelProgress = 6
        user.unlockedDetective = true
        user.sync()

        let reloaded = User(store: store)

        XCTAssertEqual(reloaded.collected, 4_321)
        XCTAssertEqual(reloaded.deaths, 7)
        XCTAssertEqual(reloaded.jumps, 812)
        XCTAssertEqual(reloaded.powerup, 20)
        XCTAssertEqual(reloaded.worldProgress, 2)
        XCTAssertEqual(reloaded.levelProgress, 6)
        XCTAssertTrue(reloaded.unlockedDetective)
    }

    func testHighscoresAndSoulsRoundTrip() {
        user.setHighscore(4_500, world: 2, level: 3)
        user.setSouls(3, world: 2, level: 3)
        user.setHalos(1, world: 2, level: 3)

        let reloaded = User(store: store)

        XCTAssertEqual(reloaded.highscore(world: 2, level: 3), 4_500)
        XCTAssertEqual(reloaded.souls(world: 2, level: 3), 3)
        XCTAssertEqual(reloaded.halos(world: 2, level: 3), 1)
    }

    func testAchievementsRoundTrip() {
        user.collected = 1_200
        _ = user.checkAchievements()

        let reloaded = User(store: store)

        XCTAssertTrue(reloaded.hasAchievement(.thousandSouls))
        XCTAssertTrue(reloaded.hasAchievement(.collected666Souls))
        XCTAssertFalse(reloaded.hasAchievement(.fiveThousandSouls))
    }

    func testResetWipesProgressAndAchievements() {
        user.collected = 9_000
        user.worldProgress = 3
        _ = user.checkAchievements()
        user.sync()

        user.reset()

        XCTAssertEqual(user.collected, 0)
        XCTAssertEqual(user.worldProgress, 1)
        XCTAssertFalse(user.hasAchievement(.firstPlay))
        XCTAssertFalse(User(store: store).hasAchievement(.fiveThousandSouls))
    }

    // MARK: - Score setters only improve

    func testHighscoreIsOnlyWrittenWhenItImproves() {
        user.setHighscore(1_000, world: 1, level: 1)
        user.setHighscore(500, world: 1, level: 1)

        XCTAssertEqual(user.highscore(world: 1, level: 1), 1_000)
    }

    func testEqualHighscoreDoesNotOverwrite() {
        user.setHighscore(1_000, world: 1, level: 1)
        user.setHighscore(1_000, world: 1, level: 1)

        XCTAssertEqual(user.highscore(world: 1, level: 1), 1_000)
    }

    func testWorldTotalsSumTheirLevels() {
        user.setSouls(2, world: 1, level: 1)
        user.setSouls(3, world: 1, level: 2)
        user.setSouls(4, world: 2, level: 1)

        XCTAssertEqual(user.souls(world: 1), 5)
        XCTAssertEqual(user.souls(world: 2), 4)
        XCTAssertEqual(user.soulsForAllWorlds(), 9)
    }

    /// `getHalosforWorld:` in the original always read world 1's row; the port
    /// indexes the requested world.
    func testHalosPerWorldUsesTheRequestedWorld() {
        user.setHalos(1, world: 1, level: 1)
        user.setHalos(1, world: 3, level: 5)

        XCTAssertEqual(user.halos(world: 1), 1)
        XCTAssertEqual(user.halos(world: 3), 1)
        XCTAssertEqual(user.halos(world: 2), 0)
        XCTAssertEqual(user.halosForAllWorlds(), 2)
    }

    func testDetectiveWorldUsesItsOwnStorage() {
        user.setSouls(5, world: GameConstants.detectiveWorld, level: 2)

        XCTAssertEqual(user.souls(world: GameConstants.detectiveWorld, level: 2), 5)
        XCTAssertEqual(user.souls(world: 1, level: 2), 0)
        XCTAssertEqual(user.detectiveSouls[0][1], 5)
    }

    func testOutOfRangeLevelReadsReturnZeroRatherThanCrashing() {
        XCTAssertEqual(user.highscore(world: 99, level: 99), 0)
        XCTAssertEqual(user.souls(world: 0, level: 0), 0)
        XCTAssertEqual(user.halos(world: 13, level: 21), 0)
    }

    // MARK: - Economy

    func testUnlockDetectiveRequiresEnoughSouls() {
        user.collected = GameConstants.detectiveUnlockCost - 1

        XCTAssertFalse(user.unlockDetective())
        XCTAssertFalse(user.unlockedDetective)
        XCTAssertEqual(user.collected, GameConstants.detectiveUnlockCost - 1)
    }

    func testUnlockDetectiveSpendsExactlyTheCost() {
        user.collected = GameConstants.detectiveUnlockCost + 250

        XCTAssertTrue(user.unlockDetective())
        XCTAssertTrue(user.unlockedDetective)
        XCTAssertEqual(user.collected, 250)
        XCTAssertTrue(User(store: store).unlockedDetective)
    }

    func testUnlockDetectiveIsNotChargedTwice() {
        user.collected = GameConstants.detectiveUnlockCost * 2
        XCTAssertTrue(user.unlockDetective())
        XCTAssertFalse(user.unlockDetective())
        XCTAssertEqual(user.collected, GameConstants.detectiveUnlockCost)
    }

    func testLevelSkipRequiresEnoughSouls() {
        user.collected = GameConstants.skipCost - 1

        XCTAssertFalse(user.buyLevelSkip())
        XCTAssertEqual(user.levelProgress, 1)
        XCTAssertEqual(user.collected, GameConstants.skipCost - 1)
    }

    func testLevelSkipAdvancesTheLevel() {
        user.collected = GameConstants.skipCost

        XCTAssertTrue(user.buyLevelSkip())
        XCTAssertEqual(user.collected, 0)
        XCTAssertEqual(user.levelProgress, 2)
        XCTAssertTrue(user.isLevelUnlocked(world: 1, level: 2))
    }

    func testLevelSkipRollsOverIntoTheNextWorld() {
        user.levelProgress = GameConstants.levelsPerWorld
        user.collected = GameConstants.skipCost

        XCTAssertTrue(user.buyLevelSkip())
        XCTAssertEqual(user.worldProgress, 2)
        XCTAssertEqual(user.levelProgress, 1)
    }

    func testLevelSkipIsRefusedPastTheLastShippedWorld() {
        user.worldProgress = GameConstants.currentWorldsPerGame + 1
        user.levelProgress = 1
        user.collected = GameConstants.skipCost * 4

        XCTAssertFalse(user.canSkipLevel)
        XCTAssertFalse(user.buyLevelSkip())
        XCTAssertEqual(user.collected, GameConstants.skipCost * 4)
        XCTAssertEqual(user.worldProgress, GameConstants.currentWorldsPerGame + 1)
    }

    func testBuyingItemsMarksThemOwned() {
        XCTAssertFalse(user.ownsItem(4))
        user.buyItem(4)
        user.buySpecialItem(2)
        user.buyCharacter(1)

        let reloaded = User(store: store)
        XCTAssertTrue(reloaded.ownsItem(4))
        XCTAssertTrue(reloaded.ownsSpecialItem(2))
        XCTAssertTrue(reloaded.ownsCharacter(1))
        XCTAssertFalse(reloaded.ownsItem(5))
    }

    func testBuyingAnOutOfRangeItemIsIgnored() {
        user.buyItem(9_999)
        XCTAssertFalse(user.ownsItem(9_999))
    }

    // MARK: - Achievements

    func testSoulThresholdsUnlockInOrder() {
        XCTAssertEqual(user.checkAchievements(), [.firstPlay])

        user.collected = GameConstants.Threshold.souls666
        XCTAssertEqual(user.checkAchievements(), [.collected666Souls])

        user.collected = GameConstants.Threshold.souls1000
        XCTAssertEqual(user.checkAchievements(), [.thousandSouls])

        user.collected = GameConstants.Threshold.souls50000
        XCTAssertEqual(
            user.checkAchievements(),
            [.fiveThousandSouls, .tenThousandSouls, .fiftyThousandSouls]
        )
    }

    func testJustBelowAThresholdDoesNotUnlock() {
        user.collected = GameConstants.Threshold.souls666 - 1
        _ = user.checkAchievements()

        XCTAssertFalse(user.hasAchievement(.collected666Souls))
    }

    func testWorldProgressAchievements() {
        user.worldProgress = 2
        _ = user.checkAchievements()
        XCTAssertTrue(user.hasAchievement(.beatWorld1))
        XCTAssertFalse(user.hasAchievement(.beatWorld2))

        user.worldProgress = 4
        _ = user.checkAchievements()
        XCTAssertTrue(user.hasAchievement(.beatWorld3))
        XCTAssertFalse(user.hasAchievement(.beatWorld4), "world 4 also needs level 20")

        user.levelProgress = GameConstants.levelsPerWorld
        _ = user.checkAchievements()
        XCTAssertTrue(user.hasAchievement(.beatWorld4))
    }

    func testDeathAndJumpAchievements() {
        user.deaths = 1
        user.jumps = 999
        _ = user.checkAchievements()
        XCTAssertTrue(user.hasAchievement(.killed))
        XCTAssertFalse(user.hasAchievement(.died100))
        XCTAssertFalse(user.hasAchievement(.jumped1000))

        user.deaths = 100
        user.jumps = 1_000
        _ = user.checkAchievements()
        XCTAssertTrue(user.hasAchievement(.died100))
        XCTAssertTrue(user.hasAchievement(.jumped1000))
    }

    /// The original compared `== 80`; this port uses `>=` so the achievement
    /// cannot be skipped.
    func testHaloAchievementUnlocksAtEightyHalos() {
        for world in 1...GameConstants.currentWorldsPerGame {
            for level in 1...GameConstants.levelsPerWorld {
                user.setHalos(1, world: world, level: level)
            }
        }

        XCTAssertEqual(user.halosForAllWorlds(), 80)
        _ = user.checkAchievements()
        XCTAssertTrue(user.hasAchievement(.halo))
    }

    func testAchievementsAreOnlyReportedOnce() {
        user.collected = 1_000
        let first = user.checkAchievements()
        let second = user.checkAchievements()

        XCTAssertTrue(first.contains(.thousandSouls))
        XCTAssertTrue(second.isEmpty)
    }

    func testAchievementSentFlagIsSeparateFromUnlock() {
        _ = user.checkAchievements()

        XCTAssertTrue(user.hasAchievement(.firstPlay))
        XCTAssertFalse(user.hasSentAchievement(.firstPlay))

        user.markAchievementSent(.firstPlay)
        XCTAssertTrue(User(store: store).hasSentAchievement(.firstPlay))
    }

    func testAchievementGameCenterIDsMatchGameConstants() {
        XCTAssertEqual(Achievement.beatWorld4.gameCenterID, GameConstants.AchievementID.beatWorld4)
        XCTAssertEqual(Achievement.halo.gameCenterID, GameConstants.AchievementID.halo)
        XCTAssertEqual(Achievement.firstPlay.storageKey, "ach_first_play")
        XCTAssertEqual(Achievement.firstPlay.sentStorageKey, "sent_ach_first_play")
    }

    // MARK: - Level completion

    func testCompletingTheCurrentLevelAdvancesProgress() {
        let result = GameResult(
            world: 1, level: 1,
            bigCollected: 2, collected: 40, haloCollected: 1,
            timeLimit: 30, timeTaken: 20,
            pointsPerCollectable: 10, didWin: true
        )

        let unlocked = user.recordCompletedLevel(result)

        XCTAssertEqual(user.collected, 40)
        XCTAssertEqual(user.levelProgress, 2)
        XCTAssertEqual(user.worldProgress, 1)
        XCTAssertEqual(user.cacheCurrentWorld, 1)
        XCTAssertEqual(user.highscore(world: 1, level: 1), result.finalScore)
        XCTAssertEqual(user.souls(world: 1, level: 1), 2)
        XCTAssertEqual(user.halos(world: 1, level: 1), 1)
        XCTAssertTrue(unlocked.contains(.firstPlay))
    }

    func testReplayingAnOlderLevelDoesNotAdvanceProgress() {
        user.worldProgress = 2
        user.levelProgress = 5
        user.sync()

        let result = GameResult(
            world: 1, level: 1,
            bigCollected: 1, collected: 10, haloCollected: 0,
            timeLimit: 30, timeTaken: 10,
            pointsPerCollectable: 10, didWin: true
        )
        user.recordCompletedLevel(result)

        XCTAssertEqual(user.worldProgress, 2)
        XCTAssertEqual(user.levelProgress, 5)
    }

    func testCompletingTheLastLevelOfAWorldRollsOver() {
        user.worldProgress = 1
        user.levelProgress = GameConstants.levelsPerWorld
        user.sync()

        let result = GameResult(
            world: 1, level: GameConstants.levelsPerWorld,
            bigCollected: 1, collected: 5, haloCollected: 0,
            timeLimit: 30, timeTaken: 10,
            pointsPerCollectable: 10, didWin: true
        )
        user.recordCompletedLevel(result)

        XCTAssertEqual(user.worldProgress, 2)
        XCTAssertEqual(user.levelProgress, 1)
        XCTAssertTrue(user.isLevelUnlocked(world: 2, level: 1))
        XCTAssertTrue(user.hasAchievement(.beatWorld1))
    }

    func testDetectiveCompletionDoesNotTouchHalos() {
        let result = GameResult(
            world: GameConstants.detectiveWorld, level: 1,
            bigCollected: 1, collected: 10, haloCollected: 1,
            timeLimit: 30, timeTaken: 10,
            pointsPerCollectable: 10, didWin: true
        )
        user.recordCompletedLevel(result)

        XCTAssertEqual(user.halosForAllWorlds(), 0)
        XCTAssertEqual(user.souls(world: GameConstants.detectiveWorld, level: 1), 1)
    }
}

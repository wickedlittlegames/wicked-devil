import XCTest
@testable import WickedDevilCore

final class ScoringTests: XCTestCase {

    private func makePlayer() -> Player {
        let player = Player(position: Vec2(x: 160, y: 100))
        return player
    }

    private func makeCollectable(_ kind: CollectableKind, value: Int = 1, at position: Vec2 = Vec2(x: 160, y: 100)) -> Collectable {
        Collectable(
            id: "c-\(kind.rawValue)",
            position: position,
            contentSize: SizeF(width: 16, height: 16),
            kind: kind,
            value: value
        )
    }

    // MARK: - Collectables

    func testSmallCollectableCreditsTheCollectedCounter() {
        let player = makePlayer()
        let soul = makeCollectable(.small)

        let event = soul.collect(by: player)

        XCTAssertEqual(player.collected, 1)
        XCTAssertEqual(player.bigCollected, 0)
        XCTAssertTrue(soul.dead)
        XCTAssertFalse(soul.visible)
        XCTAssertEqual(event, .collected(id: soul.id, kind: .small))
    }

    func testRichDevilMultipliesSmallCollectablesOnly() {
        let player = makePlayer()
        player.setupPowerup(.richDevilIII) // x5

        makeCollectable(.small).collect(by: player)
        makeCollectable(.big).collect(by: player)
        makeCollectable(.halo).collect(by: player)

        XCTAssertEqual(player.collected, 5)
        XCTAssertEqual(player.bigCollected, 1)
        XCTAssertEqual(player.haloCollected, 1)
    }

    func testCollectableOnlyIntersectsWhenVisible() {
        let player = makePlayer()
        let soul = makeCollectable(.small)
        XCTAssertTrue(soul.isIntersecting(player))

        soul.visible = false
        XCTAssertFalse(soul.isIntersecting(player))
    }

    func testMagnetRadiusMatchesThePowerupTier() {
        XCTAssertEqual(Powerup.magnetSoul.magnetRadius, 80)
        XCTAssertEqual(Powerup.magnetSoulPlus.magnetRadius, 140)
        XCTAssertNil(Powerup.none.magnetRadius)
    }

    func testMagnetPullsTheCollectableATenthOfTheWayEachFrame() {
        let player = makePlayer()
        let soul = makeCollectable(.small, at: Vec2(x: 260, y: 100))
        let before = soul.position.x

        soul.moveTowards(player)

        // Gap is measured between bounding-box origins (bottom-left corners),
        // as the original did: 252 - 142.5 == 109.5, a tenth of which is 10.95.
        XCTAssertEqual(before - soul.position.x, 10.95, accuracy: 1e-9)
    }

    // MARK: - Final score

    private func makeResult(
        bigCollected: Int = 3,
        collected: Int = 25,
        timeLimit: Int = 30,
        timeTaken: Int = 12,
        perCollectable: Int = 10
    ) -> GameResult {
        GameResult(
            world: 1,
            level: 1,
            bigCollected: bigCollected,
            collected: collected,
            haloCollected: 0,
            timeLimit: timeLimit,
            timeTaken: timeTaken,
            pointsPerCollectable: perCollectable,
            didWin: true
        )
    }

    func testFinalScoreCombinesSoulsTimeBonusAndCollectables() {
        let result = makeResult()

        XCTAssertEqual(result.soulsScore, 3_000)
        XCTAssertEqual(result.timeBonus, 18)
        XCTAssertEqual(result.timeBonusScore, 1_800)
        XCTAssertEqual(result.collectableScore, 250)
        XCTAssertEqual(result.finalScore, 5_050)
    }

    /// The original never clamped the time bonus, so overrunning the limit
    /// actively costs points. That behaviour is preserved.
    func testTimeBonusGoesNegativeWhenTheTimeLimitExpires() {
        let result = makeResult(bigCollected: 0, collected: 0, timeLimit: 30, timeTaken: 45)

        XCTAssertEqual(result.timeBonus, -15)
        XCTAssertEqual(result.finalScore, -1_500)
    }

    func testWinningDevilRaisesPointsPerCollectable() {
        let player = makePlayer()
        player.setupPowerup(.winningDevilIII)

        XCTAssertEqual(player.perCollectable, 30)
        XCTAssertEqual(makeResult(perCollectable: player.perCollectable).collectableScore, 750)
    }

    func testExactlyOnTheTimeLimitScoresNoTimeBonus() {
        let result = makeResult(bigCollected: 0, collected: 0, timeLimit: 60, timeTaken: 60)

        XCTAssertEqual(result.timeBonusScore, 0)
        XCTAssertEqual(result.finalScore, 0)
    }

    // MARK: - Time limits

    func testTimeLimitIsDerivedFromTheTopBoundary() {
        XCTAssertEqual(GameConstants.timeLimit(forTopBoundaryY: 0), 30)
        XCTAssertEqual(GameConstants.timeLimit(forTopBoundaryY: 2_500), 30)
        XCTAssertEqual(GameConstants.timeLimit(forTopBoundaryY: 2_500.1), 60)
        XCTAssertEqual(GameConstants.timeLimit(forTopBoundaryY: 5_000), 60)
        XCTAssertEqual(GameConstants.timeLimit(forTopBoundaryY: 5_000.1), 90)
    }
}

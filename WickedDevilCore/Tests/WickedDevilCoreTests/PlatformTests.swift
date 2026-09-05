import XCTest
@testable import WickedDevilCore

final class PlatformTests: XCTestCase {

    private func makePlayer(atY y: Double = 100, velocityY: Double = -1) -> Player {
        let player = Player(position: Vec2(x: 160, y: y))
        player.velocity.y = velocityY
        return player
    }

    private func makePlatform(
        kind: PlatformKind,
        at position: Vec2 = Vec2(x: 160, y: 90),
        size: SizeF = SizeF(width: 60, height: 16),
        health: Double = 1,
        toggleGroup: Int? = nil,
        dead: Bool = false,
        requiresBigCollectables: Int = 1
    ) -> Platform {
        Platform(
            id: "p-\(kind.rawValue)-\(position.x)-\(position.y)",
            position: position,
            contentSize: size,
            kind: kind,
            toggleGroup: toggleGroup,
            requiresBigCollectables: requiresBigCollectables,
            health: health,
            dead: dead
        )
    }

    // MARK: - Landing band

    func testLandingRequiresDownwardVelocity() {
        let player = makePlayer(atY: 100, velocityY: 1)
        let platform = makePlatform(kind: .normal)

        XCTAssertTrue(platform.isPlayerLanding(player))
        XCTAssertTrue(platform.resolveCollision(with: player, platforms: [platform]).isEmpty)
    }

    func testLandingBoundsIncludeTenPointOverhangEitherSide() {
        let platform = makePlatform(kind: .normal)
        // half width 30 + 10 overhang => x in (120, 200) exclusive
        let inside = makePlayer()
        inside.position.x = 199
        XCTAssertTrue(platform.isPlayerLanding(inside))

        let outside = makePlayer()
        outside.position.x = 200
        XCTAssertFalse(platform.isPlayerLanding(outside))
    }

    func testLandingRequiresPlayerAbovePlatformCentre() {
        let platform = makePlatform(kind: .normal, at: Vec2(x: 160, y: 100))
        let below = makePlayer(atY: 100)

        XCTAssertFalse(below.position.y > platform.position.y)
        XCTAssertFalse(platform.isPlayerLanding(below))
    }

    func testLandingTopBoundExcludesPlayersTooHighAbove() {
        // top bound = 90 + (16 + 35)/2 - 4 = 111.5
        let platform = makePlatform(kind: .normal)
        let high = makePlayer(atY: 111.5)

        XCTAssertFalse(platform.isPlayerLanding(high))
        XCTAssertTrue(platform.isPlayerLanding(makePlayer(atY: 111.4)))
    }

    // MARK: - Kinds

    func testNormalPlatformBouncesAtBaseJumpSpeed() {
        let player = makePlayer()
        let platform = makePlatform(kind: .normal)

        let events = platform.resolveCollision(with: player, platforms: [platform])

        XCTAssertEqual(player.velocity.y, 5.5, accuracy: 1e-9)
        XCTAssertEqual(player.jumps, 1)
        XCTAssertEqual(player.lastPlatformTouchedID, platform.id)
        XCTAssertEqual(events, [.playerJumped(platformID: platform.id, boost: 1.0)])
    }

    func testBoostPlatformUsesTheOnePointNineFiveMultiplier() {
        let player = makePlayer()
        let platform = makePlatform(kind: .boost)

        platform.resolveCollision(with: player, platforms: [platform])

        XCTAssertEqual(player.velocity.y, 5.5 * 1.95, accuracy: 1e-9)
    }

    func testBreakablePlatformSurvivesUntilHealthRunsOut() {
        let platform = makePlatform(kind: .breakable, health: 2)

        let first = platform.resolveCollision(with: makePlayer(), platforms: [platform])
        XCTAssertEqual(first, [.playerJumped(platformID: platform.id, boost: 1.0)])
        XCTAssertFalse(platform.dead)

        let second = platform.resolveCollision(with: makePlayer(), platforms: [platform])
        XCTAssertTrue(platform.dead)
        XCTAssertFalse(platform.visible)
        XCTAssertTrue(second.contains(.platformBroke(platformID: platform.id)))
    }

    func testFeatherDevilDamageMakesBreakablesLastLonger() {
        let platform = makePlatform(kind: .breakable, health: 1)
        let player = makePlayer()
        player.setupPowerup(.featherDevilI) // damage 0.5

        platform.resolveCollision(with: player, platforms: [platform])

        XCTAssertFalse(platform.dead)
        XCTAssertEqual(platform.health, 0.5, accuracy: 1e-9)
    }

    func testDeadPlatformIsNotLandable() {
        let platform = makePlatform(kind: .normal, dead: true)
        let player = makePlayer()

        XCTAssertTrue(platform.resolveCollision(with: player, platforms: [platform]).isEmpty)
        XCTAssertEqual(player.jumps, 0)
    }

    // MARK: - Goal

    func testGoalPlatformWinsOnlyWithARequiredBigCollectable() {
        let platform = makePlatform(kind: .goal)
        let player = makePlayer()
        player.bigCollected = 0

        let losing = platform.resolveCollision(with: player, platforms: [platform])
        XCTAssertTrue(losing.contains(.levelFinished(platformID: platform.id, didWin: false)))
        XCTAssertEqual(player.velocity.y, 5.5 * 1.5, accuracy: 1e-9)

        let winner = makePlayer()
        winner.bigCollected = 1
        let winning = platform.resolveCollision(with: winner, platforms: [platform])
        XCTAssertTrue(winning.contains(.levelFinished(platformID: platform.id, didWin: true)))
    }

    func testGoalPlatformCanRequireMoreThanOneBigCollectable() {
        let platform = makePlatform(kind: .goal, requiresBigCollectables: 3)
        let player = makePlayer()
        player.bigCollected = 2

        let events = platform.resolveCollision(with: player, platforms: [platform])

        XCTAssertTrue(events.contains(.levelFinished(platformID: platform.id, didWin: false)))
    }

    // MARK: - Toggle switch

    func testSwitchFlipsTheTwoToggleGroups() {
        let groupOne = makePlatform(kind: .toggleTarget, at: Vec2(x: 40, y: 200), toggleGroup: 1)
        let groupTwo = makePlatform(kind: .toggleTarget, at: Vec2(x: 80, y: 200), toggleGroup: 2, dead: true)
        let toggle = makePlatform(kind: .switch)
        let all = [groupOne, groupTwo, toggle]
        let player = makePlayer()

        let events = toggle.resolveCollision(with: player, platforms: all)

        XCTAssertTrue(groupOne.dead)
        XCTAssertFalse(groupTwo.dead)
        XCTAssertTrue(player.toggledPlatform)
        XCTAssertTrue(events.contains(.platformsToggled(switchID: toggle.id, enabledGroup: 2)))

        // Hitting it again restores the original arrangement.
        toggle.resolveCollision(with: makePlayerReusing(player), platforms: all)
        XCTAssertFalse(groupOne.dead)
        XCTAssertTrue(groupTwo.dead)
        XCTAssertFalse(player.toggledPlatform)
    }

    private func makePlayerReusing(_ player: Player) -> Player {
        player.velocity.y = -1
        player.position = Vec2(x: 160, y: 100)
        return player
    }
}

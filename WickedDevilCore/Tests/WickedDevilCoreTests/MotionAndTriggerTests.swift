import XCTest
@testable import WickedDevilCore

/// Moving-node tweens, toggle switches and level triggers.
final class MotionAndTriggerTests: XCTestCase {

    // MARK: - NodeMotion

    func testPingPongReachesTheOffsetAtTheEndOfTheFirstLeg() {
        let motion = NodeMotion(offset: Vec2(x: 100, y: 0), durationSeconds: 2)

        XCTAssertEqual(motion.displacement(atTime: 0), .zero)
        XCTAssertEqual(motion.displacement(atTime: 1), Vec2(x: 50, y: 0))
        XCTAssertEqual(motion.displacement(atTime: 2), Vec2(x: 100, y: 0))
    }

    func testPingPongReturnsHomeAtTheEndOfTheCycle() {
        let motion = NodeMotion(offset: Vec2(x: 0, y: 60), durationSeconds: 1.5)

        XCTAssertEqual(motion.cycleSeconds, 3, accuracy: 1e-9)
        XCTAssertEqual(motion.displacement(atTime: 2.25).y, 30, accuracy: 1e-9)
        XCTAssertEqual(motion.displacement(atTime: 3).y, 0, accuracy: 1e-9)
        // ...and keeps repeating.
        XCTAssertEqual(motion.displacement(atTime: 4.5).y, 60, accuracy: 1e-9)
    }

    func testZeroDurationMotionNeverMoves() {
        let motion = NodeMotion(offset: Vec2(x: 100, y: 100), durationSeconds: 0)
        XCTAssertEqual(motion.displacement(atTime: 5), .zero)
    }

    func testNegativeTimeIsWrappedIntoTheCycle() {
        let motion = NodeMotion(offset: Vec2(x: 100, y: 0), durationSeconds: 2)
        XCTAssertEqual(motion.displacement(atTime: -1).x, 50, accuracy: 1e-9)
    }

    // MARK: - Toggle switches

    private func makeToggleSet() -> (Platform, Platform, Platform) {
        let toggleSwitch = Platform(
            id: "switch",
            position: Vec2(x: 160, y: 100),
            contentSize: SizeF(width: 64, height: 19),
            kind: .switch,
            legacyTag: 5
        )
        let groupOne = Platform(
            id: "g1",
            position: Vec2(x: 60, y: 300),
            contentSize: SizeF(width: 64, height: 19),
            kind: .toggleTarget,
            legacyTag: 51,
            toggleGroup: 1
        )
        let groupTwo = Platform(
            id: "g2",
            position: Vec2(x: 260, y: 300),
            contentSize: SizeF(width: 64, height: 19),
            kind: .toggleTarget,
            legacyTag: 52,
            toggleGroup: 2,
            dead: true
        )
        return (toggleSwitch, groupOne, groupTwo)
    }

    private func land(_ player: Player, on platform: Platform) {
        player.position = Vec2(x: platform.position.x, y: platform.position.y + 5)
        player.velocity.y = -4
    }

    func testHittingTheSwitchTwiceReturnsTheGroupsToTheirStartState() {
        let (toggleSwitch, groupOne, groupTwo) = makeToggleSet()
        let all = [toggleSwitch, groupOne, groupTwo]
        let player = Player()

        land(player, on: toggleSwitch)
        toggleSwitch.resolveCollision(with: player, platforms: all)
        XCTAssertTrue(groupOne.dead)
        XCTAssertFalse(groupTwo.dead)

        land(player, on: toggleSwitch)
        toggleSwitch.resolveCollision(with: player, platforms: all)
        XCTAssertFalse(groupOne.dead)
        XCTAssertTrue(groupTwo.dead)
    }

    func testSwitchReportsWhichGroupItEnabled() {
        let (toggleSwitch, groupOne, groupTwo) = makeToggleSet()
        let player = Player()

        land(player, on: toggleSwitch)
        let events = toggleSwitch.resolveCollision(
            with: player,
            platforms: [toggleSwitch, groupOne, groupTwo]
        )

        XCTAssertTrue(events.contains(.platformsToggled(switchID: "switch", enabledGroup: 2)))
        XCTAssertTrue(player.toggledPlatform)
    }

    func testADisabledToggleTargetCannotBeLandedOn() {
        let (_, _, groupTwo) = makeToggleSet()
        let player = Player()

        land(player, on: groupTwo)
        XCTAssertTrue(groupTwo.resolveCollision(with: player, platforms: [groupTwo]).isEmpty)
        XCTAssertEqual(player.jumps, 0)
    }

    // MARK: - Moving platforms

    func testAMovingBreakableStopsMovingOnceItIsHit() {
        let platform = Platform(
            id: "mb",
            position: Vec2(x: 160, y: 200),
            contentSize: SizeF(width: 64, height: 19),
            kind: .movingBreakable,
            legacyTag: 66,
            motion: NodeMotion(offset: Vec2(x: 80, y: 0), durationSeconds: 2),
            health: 2
        )
        let player = Player()
        XCTAssertTrue(platform.animating)

        land(player, on: platform)
        platform.resolveCollision(with: player, platforms: [platform])

        XCTAssertFalse(platform.animating)
        XCTAssertEqual(platform.health, 1, accuracy: 1e-9)
        XCTAssertFalse(platform.dead)
    }

    // MARK: - Triggers and tips

    func testTopBoundaryTriggerFiresOnlyWhenThePlayerReachesIt() {
        let trigger = Trigger(
            id: "t1",
            position: Vec2(x: 160, y: 900),
            contentSize: SizeF(width: 448, height: 14),
            kind: .levelTopBoundary,
            legacyTag: 100
        )
        let player = Player()

        player.velocity.y = -3
        player.position = Vec2(x: 160, y: 800)
        XCTAssertFalse(trigger.isIntersecting(player))

        player.position = Vec2(x: 160, y: 900)
        XCTAssertTrue(trigger.isIntersecting(player))

        // The original only fires the trigger on the way down.
        player.velocity.y = 3
        XCTAssertFalse(trigger.isIntersecting(player))
    }

    func testInvisibleTriggersNeverFire() {
        let trigger = Trigger(
            id: "t1",
            position: Vec2(x: 160, y: 900),
            contentSize: SizeF(width: 448, height: 14),
            kind: .levelTopBoundary,
            legacyTag: 100,
            visible: false
        )
        let player = Player()
        player.velocity.y = -3
        player.position = Vec2(x: 160, y: 900)

        XCTAssertFalse(trigger.isIntersecting(player))
    }

    func testTipStartsUnfadedAndCoversItsOwnArea() {
        let tip = Tip(
            id: "tip1",
            position: Vec2(x: 160, y: 200),
            contentSize: SizeF(width: 200, height: 50)
        )

        XCTAssertFalse(tip.faded)
        XCTAssertTrue(tip.boundingBox.contains(Vec2(x: 160, y: 200)))
        XCTAssertFalse(tip.boundingBox.contains(Vec2(x: 160, y: 400)))
    }
}

import XCTest
@testable import WickedDevilCore

final class PlayerPhysicsTests: XCTestCase {

    // MARK: - Integration

    func testGravityIsAppliedOncePerFrame() {
        let player = Player(position: Vec2(x: 160, y: 200))
        player.velocity.y = 0

        player.move()

        XCTAssertEqual(player.velocity.y, -0.18, accuracy: 1e-9)
        XCTAssertEqual(player.position.y, 200 - 0.18, accuracy: 1e-9)
    }

    func testJumpSetsVelocityAndClearsAnimationLatch() {
        let player = Player()
        player.animating = true

        player.jump(player.jumpSpeed)

        XCTAssertEqual(player.velocity.y, 5.5, accuracy: 1e-9)
        XCTAssertEqual(player.animation, .jump)
    }

    /// A jump should rise, stall, then come back down through its start height.
    func testJumpArcReturnsToStartHeight() {
        let player = Player(position: Vec2(x: 160, y: 100))
        player.jump(player.jumpSpeed)

        var peak = player.position.y
        var framesToPeak = 0
        for frame in 1...200 {
            player.move()
            if player.position.y > peak {
                peak = player.position.y
                framesToPeak = frame
            }
            if player.position.y <= 100 { break }
        }

        XCTAssertGreaterThan(peak, 100)
        // v0 / g = 5.5 / 0.18 ~= 30.5 frames to the apex.
        XCTAssertEqual(framesToPeak, 30)
        // Discrete Euler apex: sum(5.5 - 0.18n) for n in 1...30 == 81.3
        XCTAssertEqual(peak - 100, 81.3, accuracy: 1e-6)
        XCTAssertLessThanOrEqual(player.position.y, 100)
    }

    func testTallDeviceUsesIPhone5Tuning() {
        let player = Player(device: .tall)
        XCTAssertEqual(player.jumpSpeed, 6.51, accuracy: 1e-9)
        XCTAssertEqual(player.gravity, 0.21, accuracy: 1e-9)
    }

    func testModifierGravityAddsToGravity() {
        let player = Player(position: Vec2(x: 0, y: 100))
        player.modifierGravity = 0.32

        player.move()

        XCTAssertEqual(player.velocity.y, -0.5, accuracy: 1e-9)
    }

    // MARK: - Fall animation state machine

    func testFallAnimationTriggersInTheShallowFallBand() {
        let player = Player(position: Vec2(x: 0, y: 500))
        player.velocity.y = -1
        player.falling = true

        player.move()

        XCTAssertFalse(player.falling)
        XCTAssertEqual(player.animation, .fall)
    }

    func testLongFallAnimationTriggersBelowMinusEightPointFive() {
        let player = Player(position: Vec2(x: 0, y: 5_000))
        player.velocity.y = -8.5

        player.move()

        XCTAssertTrue(player.falling)
        XCTAssertEqual(player.animation, .fallFar)
    }

    func testFallAnimationBandIsExclusiveAtMinusFive() {
        let player = Player(position: Vec2(x: 0, y: 500))
        player.velocity.y = -4.82 // becomes exactly -5.0 after gravity
        player.falling = true

        player.move()

        XCTAssertEqual(player.velocity.y, -5.0, accuracy: 1e-9)
        XCTAssertTrue(player.falling, "-5.0 sits outside the (-5, 0) band")
    }

    // MARK: - Horizontal control

    func testHorizontalControlIsClampedToDrag() {
        let player = Player(position: Vec2(x: 160, y: 100))
        player.controllable = true

        player.applyHorizontalControl(towardX: 300)

        XCTAssertEqual(player.position.x, 164, accuracy: 1e-9)
    }

    func testHorizontalControlIsClampedToNegativeDrag() {
        let player = Player(position: Vec2(x: 160, y: 100))
        player.controllable = true

        player.applyHorizontalControl(towardX: 0)

        XCTAssertEqual(player.position.x, 156, accuracy: 1e-9)
    }

    func testHorizontalControlMovesExactlyWhenWithinDrag() {
        let player = Player(position: Vec2(x: 160, y: 100))
        player.controllable = true

        player.applyHorizontalControl(towardX: 162)

        XCTAssertEqual(player.position.x, 162, accuracy: 1e-9)
    }

    func testQuickDevilPowerupWidensDrag() {
        let player = Player(position: Vec2(x: 160, y: 100))
        player.controllable = true
        player.setupPowerup(.quickDevilIII)

        player.applyHorizontalControl(towardX: 300)

        XCTAssertEqual(player.drag, 5.5, accuracy: 1e-9)
        XCTAssertEqual(player.position.x, 165.5, accuracy: 1e-9)
    }

    func testHorizontalControlIsIgnoredWhileUncontrollable() {
        let player = Player(position: Vec2(x: 160, y: 100))
        player.controllable = false

        player.applyHorizontalControl(towardX: 300)

        XCTAssertEqual(player.position.x, 160, accuracy: 1e-9)
    }

    // MARK: - Damage edge cases

    func testSingleHitKillsTheDefaultOneHealthPlayer() {
        let player = Player()

        let fatal = player.takeHit()

        XCTAssertTrue(fatal)
        XCTAssertFalse(player.isAlive)
        XCTAssertEqual(player.animation, .die)
    }

    func testToughDevilSurvivesTheFirstHits() {
        let player = Player()
        player.setupPowerup(.toughDevilIII) // health 1 + 3

        XCTAssertFalse(player.takeHit())
        XCTAssertFalse(player.takeHit())
        XCTAssertFalse(player.takeHit())
        XCTAssertTrue(player.takeHit())
        XCTAssertFalse(player.isAlive)
    }

    func testFeatherDevilHalvesDamageSoTwoHitsAreSurvivable() {
        let player = Player()
        player.setupPowerup(.featherDevilI)

        XCTAssertEqual(player.damage, 0.5, accuracy: 1e-9)
        XCTAssertFalse(player.takeHit(player.damage))
        XCTAssertTrue(player.takeHit(player.damage))
    }

    func testNegativeHealthIsStillDead() {
        let player = Player()
        player.health = -3

        XCTAssertFalse(player.isAlive)
    }

    func testZeroHealthIsDead() {
        let player = Player()
        player.health = 0

        XCTAssertFalse(player.isAlive)
    }
}

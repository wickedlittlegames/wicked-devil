import XCTest
@testable import WickedDevilCore

final class EnemyTests: XCTestCase {

    private func makePlayer(at position: Vec2 = Vec2(x: 160, y: 200)) -> Player {
        let player = Player()
        player.position = position
        player.controllable = true
        return player
    }

    private func makeEnemy(
        kind: EnemyKind,
        at position: Vec2,
        size: SizeF = SizeF(width: 40, height: 40),
        direction: PatrolDirection? = nil,
        teleportDestination: Vec2? = nil
    ) -> Enemy {
        Enemy(
            id: "enemy-1",
            position: position,
            contentSize: size,
            kind: kind,
            legacyTag: nil,
            patrolDirection: direction,
            teleportDestination: teleportDestination
        )
    }

    // MARK: - Bat patrol

    func testBatPatrolsRightAndWrapsToTheLeftEdge() {
        let viewport = SizeF(width: 320, height: 480)
        let bat = makeEnemy(kind: .bat, at: Vec2(x: 359, y: 100), direction: .right)

        bat.move(viewport: viewport)
        XCTAssertEqual(bat.position.x, 360, accuracy: 1e-9)

        bat.move(viewport: viewport)
        XCTAssertEqual(bat.position.x, Enemy.wrapLeftEdge, accuracy: 1e-9)
    }

    /// The original tested `position.x > -50` here, which snapped a left-moving
    /// bat to the right edge on every frame. The port wraps only once.
    func testLeftMovingBatWrapsOnlyWhenItLeavesTheScreen() {
        let viewport = SizeF(width: 320, height: 480)
        let bat = makeEnemy(kind: .bat, at: Vec2(x: 100, y: 100), direction: .left)

        for _ in 0..<10 { bat.move(viewport: viewport) }
        XCTAssertEqual(bat.position.x, 90, accuracy: 1e-9)

        // Still on screen at exactly the wrap edge; the next step crosses it.
        bat.position.x = Enemy.wrapLeftEdge
        bat.move(viewport: viewport)
        XCTAssertEqual(bat.position.x, viewport.width + Enemy.wrapRightMargin, accuracy: 1e-9)
    }

    func testNonBatsDoNotPatrol() {
        let mine = makeEnemy(kind: .mine, at: Vec2(x: 100, y: 100), direction: .right)
        mine.move(viewport: SizeF(width: 320, height: 480))
        XCTAssertEqual(mine.position.x, 100, accuracy: 1e-9)
    }

    // MARK: - Bat collisions

    func testFallingOntoABatBouncesThePlayerAndKillsTheBat() {
        let player = makePlayer(at: Vec2(x: 160, y: 210))
        player.velocity.y = -6
        let bat = makeEnemy(kind: .bat, at: Vec2(x: 160, y: 200))

        let events = bat.resolveCollision(with: player)

        XCTAssertEqual(player.velocity.y, player.jumpSpeed, accuracy: 1e-9)
        XCTAssertEqual(player.health, 1, accuracy: 1e-9)
        XCTAssertTrue(bat.dead)
        XCTAssertTrue(events.contains { if case .playerJumped = $0 { return true } else { return false } })
        XCTAssertTrue(events.contains(.enemyKilled(enemyID: bat.id)))
    }

    func testJumpingIntoABatCostsHealth() {
        let player = makePlayer(at: Vec2(x: 160, y: 195))
        player.velocity.y = 4
        player.health = 2
        let bat = makeEnemy(kind: .bat, at: Vec2(x: 160, y: 200))

        let events = bat.resolveCollision(with: player)

        XCTAssertEqual(player.health, 1, accuracy: 1e-9)
        XCTAssertTrue(bat.dead)
        XCTAssertEqual(events.first, .playerHit(sourceID: bat.id, fatal: false))
    }

    func testABatHitIsFatalOnTheLastHealthPoint() {
        let player = makePlayer(at: Vec2(x: 160, y: 195))
        player.velocity.y = 4
        let bat = makeEnemy(kind: .bat, at: Vec2(x: 160, y: 200))

        let events = bat.resolveCollision(with: player)

        XCTAssertLessThanOrEqual(player.health, 0)
        XCTAssertEqual(events.first, .playerHit(sourceID: bat.id, fatal: true))
    }

    func testDeadEnemiesStopInteracting() {
        let player = makePlayer(at: Vec2(x: 160, y: 200))
        player.velocity.y = 4
        let bat = makeEnemy(kind: .bat, at: Vec2(x: 160, y: 200))
        bat.dead = true

        XCTAssertTrue(bat.resolveCollision(with: player).isEmpty)
        XCTAssertEqual(player.health, 1, accuracy: 1e-9)
    }

    // MARK: - Mines

    /// `Enemy.m` case 2 fell through into case 22, applying two points of damage
    /// to a stationary mine. This port applies exactly one.
    func testMineAppliesASingleHitAndDisappears() {
        let player = makePlayer(at: Vec2(x: 160, y: 200))
        player.health = 2
        let mine = makeEnemy(kind: .mine, at: Vec2(x: 160, y: 200))

        let events = mine.resolveCollision(with: player)

        XCTAssertEqual(player.health, 1, accuracy: 1e-9)
        XCTAssertTrue(mine.dead)
        XCTAssertFalse(mine.visible)
        XCTAssertEqual(events, [
            .playerHit(sourceID: mine.id, fatal: false),
            .enemyKilled(enemyID: mine.id)
        ])
        // A spent mine cannot hit again.
        XCTAssertTrue(mine.resolveCollision(with: player).isEmpty)
        XCTAssertEqual(player.health, 1, accuracy: 1e-9)
    }

    // MARK: - Bubbles

    func testBubbleGrabsThePlayerLiftsThemAndReleasesControl() {
        let player = makePlayer(at: Vec2(x: 100, y: 200))
        player.velocity = Vec2(x: 0, y: -5)
        let bubble = makeEnemy(kind: .bubble, at: Vec2(x: 100, y: 205))

        let events = bubble.resolveCollision(with: player)

        XCTAssertEqual(events, [.bubbleGrabbed(enemyID: bubble.id)])
        XCTAssertTrue(player.floating)
        XCTAssertFalse(player.controllable)
        XCTAssertEqual(player.velocity, .zero)
        XCTAssertEqual(player.position, bubble.position)

        // Half of the three-second lift.
        bubble.advanceBubbleLift(deltaTime: 1.5, player: player)
        XCTAssertEqual(player.position.y, 205 + DeviceProfile.standard.bubbleLift / 2, accuracy: 1e-6)
        XCTAssertTrue(player.floating)

        bubble.advanceBubbleLift(deltaTime: 1.5, player: player)
        XCTAssertEqual(player.position.y, 205 + DeviceProfile.standard.bubbleLift, accuracy: 1e-6)
        XCTAssertFalse(player.floating)
        XCTAssertTrue(player.controllable)
        XCTAssertTrue(bubble.dead)
    }

    func testBubbleLiftDoesNotOvershootWhenGivenALongFrame() {
        let player = makePlayer(at: Vec2(x: 100, y: 200))
        let bubble = makeEnemy(kind: .bubble, at: Vec2(x: 100, y: 200))
        bubble.resolveCollision(with: player)

        bubble.advanceBubbleLift(deltaTime: 30, player: player)
        XCTAssertEqual(player.position.y, 200 + DeviceProfile.standard.bubbleLift, accuracy: 1e-6)

        // Further frames are a no-op once the lift is finished.
        bubble.advanceBubbleLift(deltaTime: 1, player: player)
        XCTAssertEqual(player.position.y, 200 + DeviceProfile.standard.bubbleLift, accuracy: 1e-6)
    }

    func testTappingAFloatingBubblePopsItAndReturnsControl() {
        let player = makePlayer(at: Vec2(x: 100, y: 200))
        let bubble = makeEnemy(kind: .bubble, at: Vec2(x: 100, y: 200))
        bubble.resolveCollision(with: player)
        bubble.advanceBubbleLift(deltaTime: 0.5, player: player)

        XCTAssertTrue(bubble.containsTouch(bubble.position))
        let events = bubble.popBubble(player)

        XCTAssertEqual(events, [.bubblePopped(enemyID: bubble.id)])
        XCTAssertTrue(player.controllable)
        XCTAssertFalse(player.floating)
        XCTAssertTrue(bubble.dead)
        // The lift stops immediately.
        let restingY = player.position.y
        bubble.advanceBubbleLift(deltaTime: 1, player: player)
        XCTAssertEqual(player.position.y, restingY, accuracy: 1e-9)
    }

    func testAnUngrabbedBubbleIgnoresTapsAndPops() {
        let player = makePlayer()
        let bubble = makeEnemy(kind: .bubble, at: Vec2(x: 100, y: 200))

        XCTAssertFalse(bubble.containsTouch(bubble.position))
        XCTAssertTrue(bubble.popBubble(player).isEmpty)
    }

    func testAFloatingPlayerCannotBeGrabbedBySecondBubble() {
        let player = makePlayer(at: Vec2(x: 100, y: 200))
        player.floating = true
        let bubble = makeEnemy(kind: .bubble, at: Vec2(x: 100, y: 200))

        XCTAssertTrue(bubble.resolveCollision(with: player).isEmpty)
    }

    // MARK: - Rocket launchers

    func testLauncherFiresOnlyWhenThePlayerIsInRange() {
        let launcher = makeEnemy(kind: .rocketLauncher, at: Vec2(x: 40, y: 400))
        let farPlayer = makePlayer(at: Vec2(x: 40, y: 400 + Enemy.proximityRadius + 10))
        XCTAssertTrue(launcher.resolveCollision(with: farPlayer).isEmpty)
        XCTAssertTrue(launcher.projectiles.isEmpty)

        let nearPlayer = makePlayer(at: Vec2(x: 40, y: 410))
        let events = launcher.resolveCollision(with: nearPlayer)

        XCTAssertEqual(launcher.projectiles.count, 1)
        XCTAssertTrue(launcher.running)
        XCTAssertEqual(events, [
            .rocketFired(enemyID: launcher.id, projectileID: launcher.projectiles[0].id)
        ])
    }

    func testARocketCrossesTheScreenAndArrives() throws {
        let launcher = makeEnemy(kind: .rocketLauncher, at: Vec2(x: 40, y: 400))
        let player = makePlayer(at: Vec2(x: 60, y: 410))
        launcher.resolveCollision(with: player)
        let rocket = try XCTUnwrap(launcher.projectiles.first)

        XCTAssertGreaterThan(rocket.duration, 0)
        XCTAssertEqual(rocket.destination.x, 0, accuracy: 1e-9)
        XCTAssertFalse(rocket.hasArrived)

        rocket.advance(deltaTime: rocket.duration / 2)
        XCTAssertEqual(
            rocket.position.x,
            (rocket.origin.x + rocket.destination.x) / 2,
            accuracy: 1e-6
        )

        rocket.advance(deltaTime: rocket.duration)
        XCTAssertTrue(rocket.hasArrived)
        XCTAssertEqual(rocket.position.x, rocket.destination.x, accuracy: 1e-6)
    }

    /// `GameLayer.m` wrote `health--; if (--health <= 0)`, taking two points for
    /// a single rocket. This port takes one.
    func testARocketHitCostsExactlyOneHealthPoint() {
        let launcher = makeEnemy(kind: .rocketLauncher, at: Vec2(x: 40, y: 400))
        let player = makePlayer(at: Vec2(x: 40, y: 410))
        player.health = 3
        launcher.resolveCollision(with: player)

        // Park the player right on top of the rocket.
        let rocket = launcher.projectiles[0]
        player.position = rocket.position

        let events = launcher.updateProjectiles(deltaTime: 0, player: player)

        XCTAssertEqual(player.health, 2, accuracy: 1e-9)
        XCTAssertEqual(events, [.playerHit(sourceID: rocket.id, fatal: false)])
        XCTAssertTrue(launcher.projectiles.isEmpty)
        XCTAssertFalse(launcher.running)
    }

    func testARocketThatHitsItsLauncherKillsIt() {
        let launcher = makeEnemy(kind: .rocketLauncher, at: Vec2(x: 40, y: 400))
        let player = makePlayer(at: Vec2(x: 40, y: 410))
        launcher.resolveCollision(with: player)

        // Move the player clear, and the launcher into the rocket's path.
        player.position = Vec2(x: 300, y: 50)
        launcher.position = launcher.projectiles[0].position

        let events = launcher.updateProjectiles(deltaTime: 0, player: player)

        XCTAssertEqual(events, [.enemyKilled(enemyID: launcher.id)])
        XCTAssertTrue(launcher.dead)
        XCTAssertFalse(launcher.visible)
        XCTAssertTrue(launcher.projectiles.isEmpty)
    }

    // MARK: - Black holes

    func testBlackHoleTeleportsThePlayerAndZeroesVelocity() {
        let destination = Vec2(x: 250, y: 900)
        let hole = makeEnemy(
            kind: .blackHole,
            at: Vec2(x: 100, y: 300),
            teleportDestination: destination
        )
        let player = makePlayer(at: Vec2(x: 100, y: 300))
        player.velocity = Vec2(x: 0, y: -9)

        let events = hole.resolveCollision(with: player)

        XCTAssertEqual(player.position, destination)
        XCTAssertEqual(player.velocity, .zero)
        XCTAssertEqual(events, [.playerTeleported(enemyID: hole.id, destination: destination)])
    }

    /// Edge case: some levels contain a black hole with no paired destination.
    func testBlackHoleWithoutADestinationDoesNothing() {
        let hole = makeEnemy(kind: .blackHole, at: Vec2(x: 100, y: 300))
        let player = makePlayer(at: Vec2(x: 100, y: 300))
        player.velocity = Vec2(x: 0, y: -9)

        XCTAssertTrue(hole.resolveCollision(with: player).isEmpty)
        XCTAssertEqual(player.position, Vec2(x: 100, y: 300))
        XCTAssertEqual(player.velocity.y, -9, accuracy: 1e-9)
    }

    // MARK: - Kind mapping

    func testLegacyTagsMapToTheOriginalEnemyKinds() {
        XCTAssertEqual(EnemyKind.from(legacyTag: 1), .bat)
        XCTAssertEqual(EnemyKind.from(legacyTag: 101), .bat)
        XCTAssertEqual(EnemyKind.from(legacyTag: 2), .mine)
        XCTAssertEqual(EnemyKind.from(legacyTag: 22), .mine)
        XCTAssertEqual(EnemyKind.from(legacyTag: 223), .mine)
        XCTAssertEqual(EnemyKind.from(legacyTag: 3), .bubble)
        XCTAssertEqual(EnemyKind.from(legacyTag: 4), .rocketLauncher)
        XCTAssertEqual(EnemyKind.from(legacyTag: 5), .blackHole)
        XCTAssertEqual(EnemyKind.from(legacyTag: 6), .angelLaser)
        XCTAssertEqual(EnemyKind.from(legacyTag: 999), .unknown)
        XCTAssertEqual(EnemyKind.from(legacyTag: nil), .unknown)
    }
}

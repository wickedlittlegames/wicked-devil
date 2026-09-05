import XCTest
@testable import WickedDevilCore

final class GameWorldTests: XCTestCase {

    private func makeLevel(
        platforms: [Level.PlatformData] = [],
        collectables: [Level.CollectableData] = [],
        enemies: [Level.EnemyData] = [],
        topBoundaryY: Double = 900,
        timeLimit: Int = 30,
        spawn: Vec2 = Vec2(x: 160, y: 60)
    ) -> Level {
        Level(
            schemaVersion: "1.1.0",
            source: Level.Source(world: 1, level: 1),
            coordinateSpace: Level.CoordinateSpace(
                kind: "points",
                logicalViewport: SizeF(width: 320, height: 480)
            ),
            metadata: Level.Metadata(
                theme: "hell",
                backgroundImage: "bg.png",
                timeLimitSeconds: timeLimit,
                topBoundaryY: topBoundaryY
            ),
            playerSpawn: spawn,
            platforms: platforms,
            collectables: collectables,
            enemies: enemies
        )
    }

    private func platform(
        _ id: String,
        at position: Vec2,
        kind: String = "normal",
        size: SizeF = SizeF(width: 64, height: 19)
    ) -> Level.PlatformData {
        Level.PlatformData(id: id, position: position, size: size, kind: kind)
    }

    private func collectable(
        _ id: String,
        at position: Vec2,
        kind: String = "small"
    ) -> Level.CollectableData {
        Level.CollectableData(
            id: id,
            position: position,
            size: SizeF(width: 36, height: 36),
            kind: kind
        )
    }

    private func makeWorld(_ level: Level, user: User? = nil) -> GameWorld {
        let game = Game(world: 1, level: 1, player: Player(), user: user)
        return GameWorld(game: game, level: level)
    }

    // MARK: - Wiring

    func testWorldSeedsThePlayerAndClockFromTheLevel() {
        let world = makeWorld(makeLevel(timeLimit: 60, spawn: Vec2(x: 120, y: 75)))

        XCTAssertEqual(world.player.position, Vec2(x: 120, y: 75))
        XCTAssertEqual(world.game.timeLimit, 60)
        XCTAssertEqual(world.topBoundaryY, 900, accuracy: 1e-9)
    }

    func testUpdateIsANoOpBeforeTheRunStarts() {
        let world = makeWorld(makeLevel())
        let spawn = world.player.position

        XCTAssertTrue(world.update(deltaTime: 1.0 / 60).isEmpty)
        XCTAssertEqual(world.player.position, spawn)
    }

    func testStartingTheRunJumpsThePlayer() {
        let world = makeWorld(makeLevel())
        world.game.start()

        XCTAssertTrue(world.game.isStarted)
        XCTAssertTrue(world.player.controllable)
        XCTAssertEqual(world.player.velocity.y, world.player.jumpSpeed, accuracy: 1e-9)
    }

    func testGravityIntegratesOverFramesOnceStarted() {
        let world = makeWorld(makeLevel())
        world.game.start()
        let startY = world.player.position.y

        for _ in 0..<5 { world.update(deltaTime: 1.0 / 60) }

        // Five frames of the standard jump arc: 5.5 - 0.18n, n = 1...5.
        let expected = (1...5).reduce(0.0) { $0 + 5.5 - 0.18 * Double($1) }
        XCTAssertEqual(world.player.position.y - startY, expected, accuracy: 1e-9)
    }

    // MARK: - Game over

    func testFallingOutOfTheLevelEndsTheRun() {
        let world = makeWorld(makeLevel())
        world.game.start()
        world.player.position.y = GameConstants.playerDeathY - 100

        let events = world.update(deltaTime: 1.0 / 60)

        XCTAssertTrue(world.game.isGameover)
        XCTAssertTrue(events.contains(.gameOver(didWin: false)))
        // Falling out is not a "death" for stats purposes; the player still lives.
        XCTAssertTrue(world.player.isAlive)
        XCTAssertEqual(world.player.deaths, 0)
    }

    func testRunningOutOfHealthCountsAsADeathAndBanksStats() {
        let user = User(store: InMemoryUserDataStore())
        let world = makeWorld(makeLevel(), user: user)
        world.game.start()
        world.player.jumps = 7
        world.player.health = 0

        let events = world.update(deltaTime: 1.0 / 60)

        XCTAssertTrue(events.contains(.gameOver(didWin: false)))
        XCTAssertEqual(world.player.deaths, 1)
        XCTAssertEqual(user.deaths, 1)
        XCTAssertEqual(user.jumps, 7)
    }

    func testNegativeHealthIsStillJustOneDeath() {
        let user = User(store: InMemoryUserDataStore())
        let world = makeWorld(makeLevel(), user: user)
        world.game.start()
        world.player.health = -5

        world.update(deltaTime: 1.0 / 60)
        world.update(deltaTime: 1.0 / 60)

        XCTAssertEqual(user.deaths, 1)
    }

    func testUpdatesStopAfterGameOver() {
        let world = makeWorld(makeLevel())
        world.game.start()
        world.player.health = 0
        world.update(deltaTime: 1.0 / 60)

        let restingPosition = world.player.position
        XCTAssertTrue(world.update(deltaTime: 1.0 / 60).isEmpty)
        XCTAssertEqual(world.player.position, restingPosition)
    }

    func testGameOverEventIsEmittedOnlyOnce() {
        let world = makeWorld(makeLevel())
        world.game.start()
        world.player.health = 0

        XCTAssertEqual(world.update(deltaTime: 1.0 / 60).filter { $0 == .gameOver(didWin: false) }.count, 1)
        XCTAssertNil(world.game.checkGameOver())
    }

    // MARK: - Platforms and collectables in the loop

    func testLandingOnAPlatformBouncesThePlayer() {
        let level = makeLevel(platforms: [platform("p1", at: Vec2(x: 160, y: 120))])
        let world = makeWorld(level)
        world.game.start()
        // Placed so the frame's gravity step lands the player on the platform.
        world.player.position = Vec2(x: 160, y: 130)
        world.player.velocity.y = -4

        let events = world.update(deltaTime: 1.0 / 60)

        XCTAssertTrue(events.contains { if case .playerJumped = $0 { return true } else { return false } })
        XCTAssertGreaterThan(world.player.velocity.y, 0)
        XCTAssertEqual(world.player.jumps, 1)
    }

    func testCollectingAPickupScoresAndRemovesIt() {
        let level = makeLevel(collectables: [
            collectable("c1", at: Vec2(x: 160, y: 65)),
            collectable("c2", at: Vec2(x: 10, y: 800))
        ])
        let world = makeWorld(level)
        world.game.start()
        world.player.position = Vec2(x: 160, y: 65)

        let events = world.update(deltaTime: 1.0 / 60)

        XCTAssertTrue(events.contains { if case .collected = $0 { return true } else { return false } })
        XCTAssertEqual(world.player.collected, 1)
        XCTAssertEqual(world.collectables.count, 1)
    }

    func testBigCollectableCountsAsASoul() {
        let level = makeLevel(collectables: [collectable("c1", at: Vec2(x: 160, y: 65), kind: "big")])
        let world = makeWorld(level)
        world.game.start()
        world.player.position = Vec2(x: 160, y: 65)

        world.update(deltaTime: 1.0 / 60)

        XCTAssertEqual(world.player.bigCollected, 1)
        XCTAssertEqual(world.player.collected, 0)
    }

    func testCollectablesBelowTheCameraAreCulled() {
        let level = makeLevel(collectables: [
            collectable("small", at: Vec2(x: 160, y: 10)),
            collectable("big", at: Vec2(x: 200, y: 10), kind: "big")
        ])
        let world = makeWorld(level)
        world.game.start()
        // Climb far enough that both pickups are well below the camera.
        world.player.position = Vec2(x: 160, y: 2_000)

        world.update(deltaTime: 1.0 / 60)

        // Culling marks them dead; the sweep at the top of the next frame drops
        // them from the list.
        XCTAssertTrue(world.collectables.allSatisfy { $0.dead && !$0.visible })
        world.update(deltaTime: 1.0 / 60)
        XCTAssertTrue(world.collectables.isEmpty)
    }

    func testPickupsStayAliveWhileOnScreen() {
        let level = makeLevel(collectables: [collectable("c1", at: Vec2(x: 10, y: 300))])
        let world = makeWorld(level)
        world.game.start()
        world.player.position = Vec2(x: 300, y: 300)

        world.update(deltaTime: 1.0 / 60)

        XCTAssertEqual(world.collectables.count, 1)
        XCTAssertTrue(world.collectables[0].visible)
    }

    func testMovingPlatformsTweenAroundTheirSpawnPoint() {
        var data = platform("mover", at: Vec2(x: 100, y: 400), kind: "moving")
        data.legacyTag = 33
        data.behavior = Level.Behavior(
            mode: "movingHorizontal",
            offset: Vec2(x: 100, y: 0),
            durationSeconds: 2
        )
        let world = makeWorld(makeLevel(platforms: [data]))
        world.game.start()
        let mover = try! XCTUnwrap(world.platforms.first)
        XCTAssertNotNil(mover.motion)
        XCTAssertTrue(mover.animating)

        world.update(deltaTime: 1)
        XCTAssertEqual(mover.position.x, 150, accuracy: 1e-9)

        world.update(deltaTime: 1)
        XCTAssertEqual(mover.position.x, 200, accuracy: 1e-9)

        // ...and back again on the return leg.
        world.update(deltaTime: 2)
        XCTAssertEqual(mover.position.x, 100, accuracy: 1e-9)
    }

    // MARK: - Input

    func testTouchDragsThePlayerHorizontallyByAtMostTheDrag() {
        let world = makeWorld(makeLevel(spawn: Vec2(x: 160, y: 60)))
        world.game.start()
        world.setTouch(Vec2(x: 320, y: 60))

        world.update(deltaTime: 1.0 / 60)

        XCTAssertEqual(world.player.position.x, 160 + world.player.drag, accuracy: 1e-9)
    }

    func testTappingABubblePopsItThroughTheWorld() {
        let level = makeLevel(enemies: [
            Level.EnemyData(
                id: "e1",
                position: Vec2(x: 160, y: 70),
                size: SizeF(width: 49.5, height: 49.5),
                legacyTag: 3,
                kind: "bubble"
            )
        ])
        let world = makeWorld(level)
        world.game.start()
        world.player.position = Vec2(x: 160, y: 70)
        world.update(deltaTime: 1.0 / 60)

        XCTAssertTrue(world.player.floating)
        let events = world.handleTap(at: Vec2(x: 160, y: 70))

        XCTAssertEqual(events, [.bubblePopped(enemyID: "e1")])
        XCTAssertTrue(world.player.controllable)
    }

    func testTappingEmptySpaceDoesNothing() {
        let world = makeWorld(makeLevel())
        world.game.start()
        XCTAssertTrue(world.handleTap(at: Vec2(x: 5, y: 5)).isEmpty)
    }

    // MARK: - Camera

    func testCameraOnlyScrollsOnceThePlayerPassesTheMiddleOfTheScreen() {
        let world = makeWorld(makeLevel())
        world.player.position.y = 100
        XCTAssertEqual(world.cameraY, 0, accuracy: 1e-9)

        world.player.position.y = 500
        XCTAssertEqual(world.cameraY, 500 - 240, accuracy: 1e-9)

        // ...and stops at the top of the level, like CCFollow's world boundary.
        world.player.position.y = 10_000
        XCTAssertEqual(world.cameraY, world.topBoundaryY - 480, accuracy: 1e-9)
    }

    // MARK: - Parked objects

    func testParkedObjectsNeverEnterTheSimulation() {
        var parked = platform("parked", at: Vec2(x: 700, y: 100))
        parked.playable = false
        let level = makeLevel(platforms: [platform("p1", at: Vec2(x: 160, y: 120)), parked])
        let world = makeWorld(level)

        XCTAssertEqual(world.platforms.map(\.id), ["p1"])
    }
}

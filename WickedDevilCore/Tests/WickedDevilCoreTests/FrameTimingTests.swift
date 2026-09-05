import XCTest
@testable import WickedDevilCore

/// Covers the fixed-timestep clock and the viewport-aware camera.
///
/// The ported physics integrates per *frame* (`velocity.y -= gravity`, then
/// `position.y += velocity.y`), so the simulation is only correct when it is
/// stepped at the 1/60s cadence cocos2d used. These tests pin that down: the
/// game must cover the same distance per second of wall-clock time whatever the
/// display refresh rate, and a long stall must not fling the player anywhere.
final class FrameTimingTests: XCTestCase {

    private func makeLevel(
        platforms: [Level.PlatformData] = [],
        topBoundaryY: Double = 5_000,
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
                timeLimitSeconds: 30,
                topBoundaryY: topBoundaryY
            ),
            playerSpawn: spawn,
            platforms: platforms,
            collectables: [],
            enemies: []
        )
    }

    private func makeWorld(_ level: Level, viewport: SizeF? = nil) -> GameWorld {
        let game = Game(world: 1, level: 1, player: Player())
        let world = GameWorld(game: game, level: level, viewport: viewport)
        game.start()
        world.player.controllable = true
        // `Game.start` launches the player with a jump; these tests want a
        // stationary starting point so a single step's effect is readable.
        world.player.velocity = .zero
        return world
    }

    // MARK: - Refresh-rate independence

    func testOneSecondOfRealTimeRunsSixtyStepsWhateverTheRefreshRate() {
        // 60Hz, 120Hz ProMotion, and an uneven 45Hz all cover one second.
        let deltas = [1.0 / 60.0, 1.0 / 120.0, 1.0 / 45.0]
        var results: [Double] = []

        for delta in deltas {
            let world = makeWorld(makeLevel())
            world.player.jump(world.player.jumpSpeed)

            var elapsed = 0.0
            while elapsed < 1.0 - 1e-9 {
                world.advance(realDeltaTime: delta)
                elapsed += delta
            }
            results.append(world.player.position.y)
        }

        // Every refresh rate lands within one fixed step's worth of travel.
        let sixtyHz = results[0]
        for value in results.dropFirst() {
            XCTAssertEqual(value, sixtyHz, accuracy: 12.0)
        }
    }

    func testAdvanceRunsExactlyOneStepPerSixtiethOfASecond() {
        let world = makeWorld(makeLevel())
        let gravity = world.player.gravity

        world.advance(realDeltaTime: GameWorld.fixedTimeStep)
        XCTAssertEqual(world.player.velocity.y, -gravity, accuracy: 1e-9)

        // A 120Hz frame banks half a step and moves nothing...
        let world2 = makeWorld(makeLevel())
        world2.advance(realDeltaTime: GameWorld.fixedTimeStep / 2)
        XCTAssertEqual(world2.player.velocity.y, 0, accuracy: 1e-9)
        // ...and the next one spends it.
        world2.advance(realDeltaTime: GameWorld.fixedTimeStep / 2)
        XCTAssertEqual(world2.player.velocity.y, -gravity, accuracy: 1e-9)
    }

    func testSubStepFramesAccumulateRatherThanBeingLost() {
        let world = makeWorld(makeLevel())
        // Ten 1/600s frames == one whole step, no more, no less.
        for _ in 0..<10 { world.advance(realDeltaTime: 1.0 / 600.0) }
        XCTAssertEqual(world.player.velocity.y, -world.player.gravity, accuracy: 1e-9)
    }

    // MARK: - Stall protection

    func testALongStallIsClampedToTheCatchUpBudget() {
        let world = makeWorld(makeLevel())
        let gravity = world.player.gravity

        // Ten seconds backgrounded: only the budgeted steps may run.
        world.advance(realDeltaTime: 10)

        XCTAssertEqual(
            world.player.velocity.y,
            -gravity * Double(GameWorld.maxStepsPerFrame),
            accuracy: 1e-9
        )
        XCTAssertEqual(
            world.elapsedTime,
            GameWorld.fixedTimeStep * Double(GameWorld.maxStepsPerFrame),
            accuracy: 1e-9
        )
    }

    func testNonPositiveOrNonFiniteDeltasAreIgnored() {
        let world = makeWorld(makeLevel())
        XCTAssertTrue(world.advance(realDeltaTime: 0).isEmpty)
        XCTAssertTrue(world.advance(realDeltaTime: -1).isEmpty)
        XCTAssertTrue(world.advance(realDeltaTime: .nan).isEmpty)
        XCTAssertTrue(world.advance(realDeltaTime: .infinity).isEmpty)
        XCTAssertEqual(world.player.velocity.y, 0, accuracy: 1e-9)
        XCTAssertEqual(world.elapsedTime, 0, accuracy: 1e-9)
    }

    func testResetStepAccumulatorDropsBankedTime() {
        let world = makeWorld(makeLevel())
        world.advance(realDeltaTime: GameWorld.fixedTimeStep * 0.9)
        world.resetStepAccumulator()
        world.advance(realDeltaTime: GameWorld.fixedTimeStep * 0.9)
        // Without the reset the two partial frames would have run a step.
        XCTAssertEqual(world.player.velocity.y, 0, accuracy: 1e-9)
    }

    /// The reason `advance` exists at all: the ported player physics integrates
    /// per *step*, not per second, so `update(deltaTime:)` moves the player by
    /// exactly the same amount whatever it is handed. Driving it straight from
    /// the display link would therefore run the game at double speed on a 120Hz
    /// panel and in slow motion whenever frames were dropped.
    func testRawUpdateIgnoresDeltaTimeForPlayerPhysics() {
        let slow = makeWorld(makeLevel())
        let fast = makeWorld(makeLevel())

        slow.update(deltaTime: 1.0 / 60.0)
        fast.update(deltaTime: 1.0 / 120.0)

        XCTAssertEqual(slow.player.position.y, fast.player.position.y, accuracy: 1e-9)
    }

    /// Time-based sub-systems (rockets fly at a fixed speed *per second*) do
    /// scale with the delta, so an unbounded frame really can skip one straight
    /// through the player. The step budget makes that impossible.
    func testAStalledFrameCannotSkipAProjectilePastThePlayer() {
        let flightTime = 1.0
        let projectile = Projectile(
            id: "r1",
            ownerID: "e1",
            origin: Vec2(x: 160, y: 400),
            destination: Vec2(x: 160, y: 0),
            duration: flightTime
        )

        // Handed a whole second in one go, the rocket teleports past the player.
        projectile.advance(deltaTime: flightTime)
        XCTAssertFalse(projectile.isIntersecting(playerAt(Vec2(x: 160, y: 200))))

        // Stepped through the same second at the fixed cadence it always hits.
        let stepped = Projectile(
            id: "r2",
            ownerID: "e1",
            origin: Vec2(x: 160, y: 400),
            destination: Vec2(x: 160, y: 0),
            duration: flightTime
        )
        var hit = false
        for _ in 0..<60 {
            stepped.advance(deltaTime: GameWorld.fixedTimeStep)
            if stepped.isIntersecting(playerAt(Vec2(x: 160, y: 200))) { hit = true }
        }
        XCTAssertTrue(hit, "A fixed-step flight should sweep through the player")
    }

    private func playerAt(_ position: Vec2) -> Player {
        let player = Player()
        player.position = position
        return player
    }

    // MARK: - Camera

    func testTallViewportKeepsTheOriginalAmountOfWorldBelowThePlayer() {
        let world = makeWorld(makeLevel(), viewport: SizeF(width: 320, height: 696))
        XCTAssertEqual(world.cameraAnchorHeight, 240, accuracy: 1e-9)

        world.player.position.y = 1_000
        // Bottom of the screen is still 240pt below him, exactly as on a 480pt
        // screen; the extra 216pt of height is look-ahead above.
        XCTAssertEqual(world.cameraY, 760, accuracy: 1e-9)
    }

    func testCameraCeilingFollowsTheMeasuredViewportNotTheAuthoredOne() {
        let level = makeLevel(topBoundaryY: 2_000)
        let world = makeWorld(level, viewport: SizeF(width: 320, height: 696))
        world.player.position.y = 100_000
        // Stopping at topBoundaryY - 480 would show 216pt of void above the level.
        XCTAssertEqual(world.cameraY, 2_000 - 696, accuracy: 1e-9)
    }

    func testViewportNeverShrinksBelowTheAuthoredDesignBox() {
        // A 4:3 iPad column is shorter than 480pt once the width is fixed; the
        // world refuses it so levels are never cropped vertically.
        let world = makeWorld(makeLevel(), viewport: SizeF(width: 360, height: 426))
        XCTAssertEqual(world.viewport.height, 480, accuracy: 1e-9)
        XCTAssertEqual(world.viewport.width, 360, accuracy: 1e-9)
        XCTAssertEqual(world.cameraAnchorHeight, 240, accuracy: 1e-9)
    }

    func testDefaultViewportMatchesTheDeviceProfile() {
        let world = makeWorld(makeLevel())
        XCTAssertEqual(world.viewport.width, 320, accuracy: 1e-9)
        XCTAssertEqual(world.viewport.height, 480, accuracy: 1e-9)
    }

    // MARK: - Touch clamping

    func testTouchIsClampedToThePlayField() {
        let world = makeWorld(makeLevel(), viewport: SizeF(width: 400, height: 700))
        XCTAssertEqual(world.playFieldWidth, 320, accuracy: 1e-9)

        world.setTouch(Vec2(x: -60, y: 10))
        XCTAssertEqual(world.game.touch.x, 0, accuracy: 1e-9)

        world.setTouch(Vec2(x: 999, y: 10))
        XCTAssertEqual(world.game.touch.x, 320, accuracy: 1e-9)

        world.setTouch(Vec2(x: 175, y: 10))
        XCTAssertEqual(world.game.touch.x, 175, accuracy: 1e-9)
    }
}

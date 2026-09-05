import XCTest
@testable import WickedDevilCore

final class LevelDecodingTests: XCTestCase {

    /// Walks up from this file to the repository root so the tests can read the
    /// real converter output without duplicating it into the package.
    private static var repositoryRoot: URL = {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            url.deleteLastPathComponent()
            if FileManager.default.fileExists(
                atPath: url.appendingPathComponent("tools/ccbi-converter").path
            ) {
                return url
            }
        }
        XCTFail("Could not locate the repository root from \(#filePath)")
        return url
    }()

    private func sampleURL(_ name: String) -> URL {
        LevelDecodingTests.repositoryRoot
            .appendingPathComponent("tools/ccbi-converter/samples")
            .appendingPathComponent(name)
    }

    private func shippedURL(_ name: String) -> URL {
        LevelDecodingTests.repositoryRoot
            .appendingPathComponent("WickedLittleDevilSwift/Resources/Levels")
            .appendingPathComponent(name)
    }

    private func load(_ url: URL) throws -> Level {
        try XCTUnwrap(try Level.load(contentsOf: url))
    }

    // MARK: - Schema 1.0.0 samples

    func testDecodesWorldOneLevelOne() throws {
        let level = try load(sampleURL("world-1-level-1.json"))

        XCTAssertEqual(level.schemaVersion, "1.0.0")
        XCTAssertEqual(level.source.world, 1)
        XCTAssertEqual(level.source.level, 1)
        XCTAssertEqual(level.coordinateSpace.logicalViewport, SizeF(width: 320, height: 480))
        XCTAssertEqual(level.metadata.theme, "hell")
        XCTAssertEqual(level.metadata.timeLimitSeconds, 30)
        XCTAssertEqual(level.playerSpawn, Vec2(x: 160, y: 60))
        XCTAssertEqual(level.platforms.count, 6)
        XCTAssertEqual(level.collectables.count, 4)
    }

    /// Edge case: the tutorial level has no enemies at all.
    func testLevelWithZeroEnemiesDecodesAndSimulates() throws {
        let level = try load(sampleURL("world-1-level-1.json"))

        XCTAssertTrue(level.enemies.isEmpty)
        XCTAssertTrue(level.projectileSpawners.isEmpty)

        let entities = level.makeEntities()
        XCTAssertTrue(entities.enemies.isEmpty)
        XCTAssertFalse(entities.platforms.isEmpty)
    }

    func testDecodesTheTallestWorldOneLevel() throws {
        let level = try load(sampleURL("world-1-level-20.json"))

        XCTAssertEqual(level.platforms.count, 40)
        XCTAssertEqual(level.collectables.count, 266)
        XCTAssertEqual(level.enemies.count, 3)
        XCTAssertEqual(level.metadata.timeLimitSeconds, 60)
        XCTAssertEqual(level.metadata.topBoundaryY, 3_715.867, accuracy: 1e-3)
        // The derived rule must agree with the value the converter baked in.
        XCTAssertEqual(level.derivedTimeLimitSeconds, level.metadata.timeLimitSeconds)
    }

    func testGoalIsDecodedWithItsPlatform() throws {
        let level = try load(sampleURL("world-1-level-20.json"))
        let goal = try XCTUnwrap(level.goal)

        XCTAssertEqual(goal.requiresBigCollectables, 1)
        XCTAssertEqual(goal.platformId, "platform-003")
        XCTAssertEqual(level.requiredBigCollectables, 1)

        let goalPlatform = try XCTUnwrap(
            level.makeEntities().platforms.first { $0.id == goal.platformId }
        )
        XCTAssertEqual(goalPlatform.kind, .goal)
        XCTAssertEqual(goalPlatform.legacyTag, 100)
    }

    func testHeterogeneousBehaviorPayloadsDecode() throws {
        let level = try load(sampleURL("world-1-level-20.json"))

        let mover = try XCTUnwrap(level.platforms.first { $0.kind == "moving" })
        let behavior = try XCTUnwrap(mover.behavior)
        XCTAssertTrue(behavior.mode.hasPrefix("moving"))
        XCTAssertNotNil(behavior.motion)

        let bat = try XCTUnwrap(level.enemies.first { $0.kind == "bat" })
        XCTAssertEqual(bat.behavior?.mode, "horizontalPatrol")
        XCTAssertEqual(bat.behavior?.direction, "right")
        XCTAssertEqual(bat.behavior?.wrapsAtViewportEdge, true)
    }

    func testEnemyRichLevelMapsEveryKind() throws {
        let level = try load(sampleURL("world-3-level-17.json"))

        XCTAssertEqual(level.enemies.count, 14)
        let kinds = Set(level.makeEntities(includingParked: true).enemies.map(\.kind))
        XCTAssertFalse(kinds.contains(.unknown))
        XCTAssertTrue(kinds.contains(.bubble))
    }

    func testProjectileSpawnerDecodes() throws {
        let level = try load(sampleURL("world-4-level-7.json"))
        let spawner = try XCTUnwrap(level.projectileSpawners.first)

        XCTAssertEqual(spawner.kind, "rocket")
        XCTAssertGreaterThan(spawner.projectileSpeed, 0)
        XCTAssertTrue(level.enemies.contains { $0.id == spawner.sourceEnemyId })
    }

    func testDetectiveLevelDecodesWithItsOwnTheme() throws {
        let level = try load(sampleURL("world-20-level-1.json"))

        XCTAssertEqual(level.source.world, GameConstants.detectiveWorld)
        XCTAssertEqual(level.metadata.theme, "detective")
    }

    func testTopBoundaryTriggerIsDecoded() throws {
        let level = try load(sampleURL("world-1-level-20.json"))
        let entities = level.makeEntities()

        let top = try XCTUnwrap(entities.triggers.first { $0.kind == .levelTopBoundary })
        XCTAssertEqual(top.position.y, level.metadata.topBoundaryY, accuracy: 1e-3)
    }

    // MARK: - Schema 1.1.0 shipped catalogue

    func testEveryShippedLevelDecodes() throws {
        let directory = LevelDecodingTests.repositoryRoot
            .appendingPathComponent("WickedLittleDevilSwift/Resources/Levels")
        let files = try FileManager.default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }

        XCTAssertEqual(files.count, 91)
        for file in files {
            let level = try load(file)
            XCTAssertFalse(level.platforms.isEmpty, "\(file.lastPathComponent) has no platforms")
            XCTAssertEqual(
                level.derivedTimeLimitSeconds,
                level.metadata.timeLimitSeconds,
                "\(file.lastPathComponent) time limit mismatch"
            )
        }
    }

    func testParkedObjectsAreSkippedByDefault() throws {
        let level = try load(shippedURL("world-3-level-17.json"))

        XCTAssertEqual(level.schemaVersion, "1.1.0")
        let parkedPlatforms = level.platforms.filter { $0.playable == false }
        XCTAssertFalse(parkedPlatforms.isEmpty, "this level is expected to have parked objects")

        let playable = level.makeEntities()
        let all = level.makeEntities(includingParked: true)

        XCTAssertEqual(playable.platforms.count, level.platforms.count - parkedPlatforms.count)
        XCTAssertEqual(all.platforms.count, level.platforms.count)
        XCTAssertTrue(playable.platforms.allSatisfy { platform in
            level.platforms.first { $0.id == platform.id }?.playable != false
        })
    }

    func testPlayableCollectableCountsMatchTheFilteredEntities() throws {
        let level = try load(shippedURL("world-3-level-17.json"))
        let counts = try XCTUnwrap(level.metadata.playableCollectables)
        let entities = level.makeEntities()

        XCTAssertEqual(entities.collectables.filter { $0.kind == .small }.count, counts.small)
        XCTAssertEqual(entities.collectables.filter { $0.kind == .big }.count, counts.big)
        XCTAssertEqual(entities.collectables.filter { $0.kind == .halo }.count, counts.halo)
    }

    func testUnknownKindsFallBackInsteadOfThrowing() throws {
        let json = """
        {
          "schemaVersion": "9.9.9",
          "source": { "world": 1, "level": 1 },
          "coordinateSpace": { "kind": "points", "logicalViewport": { "width": 320, "height": 480 } },
          "metadata": {
            "theme": "hell", "backgroundImage": "bg.png",
            "timeLimitSeconds": 30, "topBoundaryY": 900
          },
          "playerSpawn": { "x": 160, "y": 60 },
          "platforms": [
            {
              "id": "p1",
              "position": { "x": 10, "y": 20 },
              "size": { "width": 64, "height": 19 },
              "kind": "teleporterOfTheFuture"
            },
            {
              "id": "p2",
              "position": { "x": 10, "y": 60 },
              "size": { "width": 64, "height": 19 },
              "legacyTag": 4242,
              "kind": "teleporterOfTheFuture"
            }
          ]
        }
        """
        let level = try Level.decode(from: Data(json.utf8))

        XCTAssertTrue(level.collectables.isEmpty)
        XCTAssertTrue(level.enemies.isEmpty)
        XCTAssertNil(level.goal)
        // An unrecognised kind string falls back to the legacy tag, and a
        // missing tag means "normal platform" exactly as in the original game.
        let platforms = level.makeEntities().platforms
        XCTAssertEqual(platforms.first?.kind, .normal)
        XCTAssertEqual(platforms.last?.kind, .unknown)
    }
}

import XCTest
import WickedDevilCore
@testable import WickedLittleDevilSwift

/// `AudioEngine.playMusic` returns quietly when `AssetLocator` cannot find the
/// track, so a music file that is not in the bundle just plays silence — the
/// same silent-failure shape `MenuBackgroundTests` was written to catch. These
/// tests make a missing or misnamed track loud.
final class MusicTrackTests: XCTestCase {

    private func assertTrackIsBundled(
        _ name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension
        XCTAssertFalse(
            ext.isEmpty,
            "track \(name) should carry its extension, as AudioEngine only defaults to aifc",
            file: file,
            line: line
        )
        XCTAssertNotNil(
            AssetLocator.url(forResource: base, withExtension: ext),
            "missing music track \(name)",
            file: file,
            line: line
        )
    }

    /// The menus' track and the detective campaign's track.
    func testNamedTracksAreBundled() {
        assertTrackIsBundled(MusicTrack.menu)
        assertTrackIsBundled(MusicTrack.detective)
    }

    /// Every world that ships a level, including the bonus and detective
    /// worlds, resolves to a track that is actually in the bundle.
    func testEveryShippedWorldHasBundledMusic() {
        let worlds = LevelInventory.bundled.levelCounts.filter { $0.value > 0 }.keys
        XCTAssertFalse(worlds.isEmpty, "no levels found in the bundle")

        for world in worlds.sorted() {
            let track = try? XCTUnwrap(
                LevelCatalog.musicTrack(world: world),
                "world \(world) has no music track"
            )
            guard let track else { continue }
            assertTrackIsBundled(track)
        }
    }

    /// `AdventureSelectScene.m` started the detective track and `GameScene.m`
    /// deliberately let it carry into world 20. The menus now stop their music
    /// when a run starts, so the detective levels must name the track
    /// themselves or they play in silence.
    func testDetectiveLevelsUseTheDetectiveTrack() {
        XCTAssertEqual(
            LevelCatalog.musicTrack(world: GameConstants.detectiveWorld),
            MusicTrack.detective
        )
    }

    /// `GameScene.m:72` — world 11 swapped in the menu track.
    func testBonusLevelUsesTheMenuTrack() {
        XCTAssertEqual(
            LevelCatalog.musicTrack(world: GameConstants.bonusWorld),
            MusicTrack.menu
        )
    }
}

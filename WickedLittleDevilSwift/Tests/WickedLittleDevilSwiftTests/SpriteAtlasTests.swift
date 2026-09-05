import XCTest
@testable import WickedLittleDevilSwift

/// Covers the sheet-resolution rules in `SpriteLibrary.frame(named:sheet:)`.
///
/// These run against the real bundled art, because the thing under test is
/// whether the shipped level data still resolves — a mocked atlas would only
/// prove the code does what it says, not that world 20 draws.
final class SpriteAtlasTests: XCTestCase {

    func testBundledSheetsAreDiscovered() {
        let names = SpriteAtlas.bundledSheetNames
        XCTAssertTrue(names.contains("IngameSprites"))
        XCTAssertTrue(names.contains("IngameSprites-bw"))
        // Particle and level plists have no `-hd` twin and must not be mistaken
        // for spritesheets.
        XCTAssertFalse(names.contains("CollectedBig"))
    }

    func testFrameResolvesFromItsDeclaredSheet() {
        XCTAssertNotNil(
            SpriteLibrary.frame(named: "ingame-platform-normal.png", sheet: "IngameSprites.plist")
        )
    }

    /// The world 20 defect: 410 nodes declare `IngameSprites.plist` for a frame
    /// that only exists in `IngameSprites-bw`. `CCBReader.m:415-423` resolved it
    /// through the shared `CCSpriteFrameCache`, so the declared sheet never
    /// mattered; a strict lookup drew these magenta.
    func testFrameResolvesFromAnotherSheetWhenTheDeclaredOneIsWrong() {
        let declared = SpriteLibrary.frame(
            named: "ingame-small-collectable-bw.png",
            sheet: "IngameSprites.plist"
        )
        XCTAssertNotNil(declared, "world 20's mis-declared collectables must still resolve")

        let correct = SpriteLibrary.frame(
            named: "ingame-small-collectable-bw.png",
            sheet: "IngameSprites-bw.plist"
        )
        XCTAssertNotNil(correct)
        XCTAssertEqual(declared?.size, correct?.size,
                       "the fallback must find the same frame the correct sheet does")
    }

    func testFrameResolvesWithNoDeclaredSheet() {
        XCTAssertNotNil(SpriteLibrary.frame(named: "ingame-mine-bw.png", sheet: nil))
    }

    func testGenuinelyMissingArtStillFails() {
        XCTAssertNil(
            SpriteLibrary.frame(named: "not-a-real-sprite.png", sheet: "IngameSprites.plist"),
            "the fallback must not invent frames — missing art has to stay visible as a problem"
        )
    }

    /// Every `spriteFrame` in every shipped level has to resolve. This is the
    /// regression net for the whole asset pipeline, not just world 20.
    func testEveryLevelSpriteFrameResolves() throws {
        let levels = AssetLocator.urls(forResourcesWithExtension: "json")
        XCTAssertFalse(levels.isEmpty, "no level data found in the bundle")

        var unresolved: Set<String> = []
        var checked = 0

        for url in levels {
            let data = try Data(contentsOf: url)
            let root = try JSONSerialization.jsonObject(with: data)
            walk(root) { frameName, sheet in
                checked += 1
                if SpriteLibrary.frame(named: frameName, sheet: sheet) == nil {
                    unresolved.insert("\(frameName) (declared: \(sheet ?? "none"))")
                }
            }
        }

        XCTAssertGreaterThan(checked, 0, "no sprite references found in the level data")
        XCTAssertTrue(unresolved.isEmpty, "unresolved sprite frames: \(unresolved.sorted())")
    }

    private func walk(_ node: Any, visit: (String, String?) -> Void) {
        if let object = node as? [String: Any] {
            if let frameName = object["spriteFrame"] as? String, !frameName.isEmpty {
                visit(frameName, object["spriteSheet"] as? String)
            }
            for value in object.values { walk(value, visit: visit) }
        } else if let array = node as? [Any] {
            for value in array { walk(value, visit: visit) }
        }
    }
}

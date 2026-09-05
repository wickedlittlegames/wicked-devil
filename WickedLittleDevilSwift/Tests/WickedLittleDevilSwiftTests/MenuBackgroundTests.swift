import UIKit
import XCTest
import WickedDevilCore
@testable import WickedLittleDevilSwift

/// `MenuBackground` (`MenuTheme.swift:87`) checks `UIImage(named:) != nil` before
/// drawing, so a background that does not exist degrades to a flat colour
/// instead of failing. That is why `StatsView` asking for `bg-stats-iphone5` —
/// an asset that has never existed, in this bundle or the original — went
/// unnoticed. These tests make a missing backdrop loud.
final class MenuBackgroundTests: XCTestCase {

    private func assertImageExists(_ name: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(UIImage(named: name), "missing menu asset \(name)", file: file, line: line)
    }

    /// Every theme's artwork, including the worlds that fall through to the
    /// "coming soon" placeholder.
    func testWorldThemeBackgroundsExist() {
        for world in [1, 2, 3, 4, 5, GameConstants.bonusWorld, GameConstants.detectiveWorld] {
            let theme = WorldTheme.theme(for: world)
            assertImageExists(theme.menuBackground)
            assertImageExists(theme.levelBackground)
        }
    }

    /// The fixed backdrops the menu screens name directly.
    func testFixedScreenBackgroundsExist() {
        for name in ["bg-home-iphone5", "bg-store-home-iphone5", "bg-store-iphone5",
                     "bg-locked-iphone5", "bg-coming-soon"] {
            assertImageExists(name)
        }
    }

    /// `StatsScene.m:70` built its backdrop from `bg-store-iphone5.png` — the
    /// Stats screen reused the shop's artwork rather than having its own.
    func testStatsUsesTheShopBackdrop() {
        assertImageExists("bg-store-iphone5")
        XCTAssertNil(UIImage(named: "bg-stats-iphone5"),
                     "if a bg-stats asset is ever added, StatsView should be pointed back at it")
    }
}

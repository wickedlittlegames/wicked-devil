import XCTest
@testable import WickedDevilCore

final class GeometryTests: XCTestCase {
    func testCenteredBoundingBoxMatchesAnchorPointHalf() {
        let rect = RectF.centered(at: Vec2(x: 100, y: 200), size: SizeF(width: 64, height: 20))
        XCTAssertEqual(rect.origin.x, 68)
        XCTAssertEqual(rect.origin.y, 190)
        XCTAssertEqual(rect.maxX, 132)
        XCTAssertEqual(rect.maxY, 210)
    }

    func testIntersectionAndDistance() {
        let a = RectF(x: 0, y: 0, width: 10, height: 10)
        let b = RectF(x: 5, y: 5, width: 10, height: 10)
        let c = RectF(x: 20, y: 20, width: 10, height: 10)
        XCTAssertTrue(a.intersects(b))
        XCTAssertFalse(a.intersects(c))
        XCTAssertEqual(Vec2(x: 0, y: 0).distance(to: Vec2(x: 3, y: 4)), 5)
    }

    func testEmptyRectNeverIntersects() {
        let empty = RectF(x: 0, y: 0, width: 0, height: 10)
        XCTAssertFalse(empty.intersects(RectF(x: 0, y: 0, width: 10, height: 10)))
    }
}

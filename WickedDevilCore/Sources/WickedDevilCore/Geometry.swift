import Foundation

/// Engine-agnostic 2D point/vector.
///
/// The original game used cocos2d's `CGPoint` (`ccp`). We deliberately avoid
/// CoreGraphics here so the package stays portable and dependency-free; the
/// SpriteKit layer can convert to `CGPoint` at the boundary.
public struct Vec2: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }

    public static let zero = Vec2(x: 0, y: 0)

    public static func + (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (lhs: Vec2, rhs: Double) -> Vec2 {
        Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    /// Euclidean distance, matching the `sqrt(xdif*xdif + ydif*ydif)` checks
    /// used by `Collectable.m` and `Enemy.m`.
    public func distance(to other: Vec2) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return (dx * dx + dy * dy).squareRoot()
    }
}

/// Engine-agnostic size, replacing cocos2d `contentSize`.
public struct SizeF: Codable, Equatable, Sendable {
    public var width: Double
    public var height: Double

    public init(width: Double = 0, height: Double = 0) {
        self.width = width
        self.height = height
    }

    public static let zero = SizeF(width: 0, height: 0)
}

/// Axis-aligned rectangle used for the bounding-box collision checks that the
/// original performed with `CGRectIntersectsRect([self worldBoundingBox], ...)`.
public struct RectF: Equatable, Sendable {
    public var origin: Vec2
    public var size: SizeF

    public init(origin: Vec2, size: SizeF) {
        self.origin = origin
        self.size = size
    }

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.init(origin: Vec2(x: x, y: y), size: SizeF(width: width, height: height))
    }

    public var minX: Double { origin.x }
    public var minY: Double { origin.y }
    public var maxX: Double { origin.x + size.width }
    public var maxY: Double { origin.y + size.height }

    public var isEmpty: Bool { size.width <= 0 || size.height <= 0 }

    /// cocos2d sprites in this game use the default anchor point (0.5, 0.5), so
    /// a node's world bounding box origin is `position - size / 2`.
    public static func centered(at position: Vec2, size: SizeF) -> RectF {
        RectF(
            origin: Vec2(x: position.x - size.width / 2, y: position.y - size.height / 2),
            size: size
        )
    }

    public func intersects(_ other: RectF) -> Bool {
        guard !isEmpty, !other.isEmpty else { return false }
        return minX < other.maxX && other.minX < maxX && minY < other.maxY && other.minY < maxY
    }

    public func contains(_ point: Vec2) -> Bool {
        point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
    }
}

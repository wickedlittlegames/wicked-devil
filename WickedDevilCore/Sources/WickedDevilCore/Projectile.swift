import Foundation

/// A projectile, ported from `Objects/Projectile.h` / `Projectile.m`.
///
/// Only rocket-launcher enemies spawn projectiles. The original moved them with
/// a `CCMoveTo`; here the flight is described by a start/destination pair plus a
/// duration so the domain layer can integrate it (and tests can assert on it).
public final class Projectile {
    public let id: String
    /// The enemy that fired this projectile.
    public let ownerID: String
    public var position: Vec2
    public var contentSize: SizeF
    public let origin: Vec2
    public let destination: Vec2
    public let duration: Double
    public private(set) var elapsed: Double
    public var visible: Bool

    /// Size of `rocket.png`.
    public static let rocketSize = SizeF(width: 18, height: 35)

    public init(
        id: String,
        ownerID: String,
        origin: Vec2,
        destination: Vec2,
        duration: Double,
        contentSize: SizeF = Projectile.rocketSize
    ) {
        self.id = id
        self.ownerID = ownerID
        self.position = origin
        self.origin = origin
        self.destination = destination
        self.duration = duration
        self.elapsed = 0
        self.contentSize = contentSize
        self.visible = true
    }

    public var boundingBox: RectF {
        RectF.centered(at: position, size: contentSize)
    }

    public var hasArrived: Bool { duration <= 0 || elapsed >= duration }

    /// Advances the linear `CCMoveTo` flight. On arrival the original hid the
    /// projectile (`action_end`).
    public func advance(deltaTime: Double) {
        guard visible else { return }
        elapsed += deltaTime
        guard duration > 0 else {
            position = destination
            visible = false
            return
        }
        let progress = min(elapsed / duration, 1.0)
        position = origin + (destination - origin) * progress
        if progress >= 1.0 { visible = false }
    }

    /// `Projectile isIntersectingPlayer:`
    public func isIntersecting(_ player: Player) -> Bool {
        visible && boundingBox.intersects(player.boundingBox)
    }

    /// `Projectile isIntersectingParent:` — rockets can destroy the launcher
    /// that fired them.
    public func isIntersecting(_ enemy: Enemy) -> Bool {
        visible && enemy.visible && boundingBox.intersects(enemy.boundingBox)
    }
}

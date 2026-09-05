import Foundation

/// The three collectable classes from `Objects/Collectable.h`.
public enum CollectableKind: String, Codable, Sendable, CaseIterable {
    /// `Collectable` — a soul; counts towards `player.collected`.
    case small
    /// `BigCollectable` — worth 1000 points and required to win the level.
    case big
    /// `HaloCollectable` — bonus pickup tracked separately.
    case halo
}

/// A pickup, ported from `Objects/Collectable.h` / `Collectable.m`.
///
/// The three original classes only differed in which counter they incremented,
/// so they collapse into one type discriminated by `kind`. Only small
/// collectables support the magnet powerups, matching `GameLayer.m`.
public final class Collectable {
    public let id: String
    public var position: Vec2
    public var contentSize: SizeF
    public let kind: CollectableKind
    /// How much the pickup is worth before the player's multiplier is applied.
    public let value: Int
    public var dead: Bool
    public var visible: Bool

    public init(
        id: String,
        position: Vec2,
        contentSize: SizeF,
        kind: CollectableKind,
        value: Int = 1,
        dead: Bool = false,
        visible: Bool = true
    ) {
        self.id = id
        self.position = position
        self.contentSize = contentSize
        self.kind = kind
        self.value = value
        self.dead = dead
        self.visible = visible
    }

    public var boundingBox: RectF {
        RectF.centered(at: position, size: contentSize)
    }

    /// `Collectable isIntersectingPlayer:` — plain bounding-box overlap.
    public func isIntersecting(_ player: Player) -> Bool {
        visible && boundingBox.intersects(player.boundingBox)
    }

    /// `Collectable radiusCheck:` — measured between *bounding box origins*
    /// (bottom-left corners), not centres, exactly as the original did.
    public func isWithin(radius: Double, of player: Player) -> Bool {
        guard visible else { return false }
        // The original always added 1 to the radius ("radiusTwo").
        return boundingBox.origin.distance(to: player.boundingBox.origin) <= radius + 1
    }

    /// `Collectable moveTowardsPlayer:` — closes a tenth of the gap per frame.
    public func moveTowards(_ player: Player) {
        let delta = boundingBox.origin - player.boundingBox.origin
        position.x -= delta.x / 10
        position.y -= delta.y / 10
    }

    /// Applies the pickup to the player and marks it consumed.
    ///
    /// `GameLayer.m` credited small collectables as
    /// `collected += 1 * collectable_multiplier`, while big and halo pickups
    /// simply incremented their counters.
    @discardableResult
    public func collect(by player: Player) -> GameEvent {
        dead = true
        visible = false
        switch kind {
        case .small:
            player.collected += value * player.collectableMultiplier
        case .big:
            player.bigCollected += value
        case .halo:
            player.haloCollected += value
        }
        return .collected(id: id, kind: kind)
    }
}

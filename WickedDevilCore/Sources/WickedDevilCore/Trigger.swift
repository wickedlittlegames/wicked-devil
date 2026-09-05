import Foundation

/// A level trigger, ported from `Objects/Trigger.h` / `Trigger.m`.
///
/// The only trigger the shipped levels use is the level-top boundary (tag 100),
/// which the game reads to size the camera and derive the time limit.
public enum TriggerKind: String, Codable, Sendable {
    case levelTopBoundary
    case trigger
}

public final class Trigger {
    public let id: String
    public var position: Vec2
    public var contentSize: SizeF
    public let kind: TriggerKind
    public let legacyTag: Int?
    public var visible: Bool

    public init(
        id: String,
        position: Vec2,
        contentSize: SizeF,
        kind: TriggerKind = .trigger,
        legacyTag: Int? = nil,
        visible: Bool = true
    ) {
        self.id = id
        self.position = position
        self.contentSize = contentSize
        self.kind = kind
        self.legacyTag = legacyTag
        self.visible = visible
    }

    public var boundingBox: RectF {
        RectF.centered(at: position, size: contentSize)
    }

    /// `Trigger isIntersectingPlayer:` — only fires while the player is falling.
    public func isIntersecting(_ player: Player) -> Bool {
        visible && player.velocity.y < 0 && boundingBox.intersects(player.boundingBox)
    }
}

/// An on-screen hint, ported from the `Tip` class in `Trigger.h`.
public final class Tip {
    public let id: String
    public var position: Vec2
    public var contentSize: SizeF
    public var faded: Bool
    public var visible: Bool

    public init(
        id: String,
        position: Vec2,
        contentSize: SizeF,
        faded: Bool = false,
        visible: Bool = true
    ) {
        self.id = id
        self.position = position
        self.contentSize = contentSize
        self.faded = faded
        self.visible = visible
    }

    public var boundingBox: RectF {
        RectF.centered(at: position, size: contentSize)
    }
}

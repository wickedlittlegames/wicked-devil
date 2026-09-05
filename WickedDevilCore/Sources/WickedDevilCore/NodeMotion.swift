import Foundation

/// Describes the ping-pong movement a moving platform / mine performs.
///
/// The original ran `CCRepeatForever(CCSequence(CCMoveBy, CCMoveBy-inverse))`.
/// The domain layer stores the parameters and can evaluate the offset for a
/// given time, so tests can reason about it without an engine; the SpriteKit
/// layer is free to drive the same values with an `SKAction`.
public struct NodeMotion: Codable, Equatable, Sendable {
    /// Offset of the first leg of the movement.
    public var offset: Vec2
    /// Duration of a single leg (the full cycle is twice this).
    public var durationSeconds: Double

    public init(offset: Vec2, durationSeconds: Double) {
        self.offset = offset
        self.durationSeconds = durationSeconds
    }

    public var cycleSeconds: Double { durationSeconds * 2 }

    /// Linear ping-pong displacement from the origin at `time` seconds.
    public func displacement(atTime time: Double) -> Vec2 {
        guard durationSeconds > 0 else { return .zero }
        let cycle = cycleSeconds
        var t = time.truncatingRemainder(dividingBy: cycle)
        if t < 0 { t += cycle }
        let progress = t <= durationSeconds
            ? t / durationSeconds
            : (cycle - t) / durationSeconds
        return offset * progress
    }
}

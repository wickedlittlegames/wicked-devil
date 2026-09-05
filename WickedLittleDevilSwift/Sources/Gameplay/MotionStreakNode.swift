import SpriteKit

/// The trail that follows the player's finger, ported from the `CCMotionStreak`
/// in `GameScene.m:200`:
///
/// ```objc
/// streak = [CCMotionStreak streakWithFade:0.5 minSeg:10 width:3
///                                   color:ccWHITE textureFilename:@"streak3.png"];
/// ```
///
/// cocos2d built one long triangle strip and gave every point a `pointState`
/// that decayed at `1/fade` per second, so the tail thinned out first and the
/// stroke vanished half a second after you stopped moving
/// (`CCMotionStreak.m:147-160`).
///
/// SpriteKit has no equivalent primitive, so the stroke is drawn as a run of
/// quads — one per segment — each fading out linearly over the same half
/// second before removing itself. The visible result is the same tail-first
/// fade; what differs is that neighbouring segments meet at a butt joint rather
/// than the mitre `ccVertexLineToPolygon` produced, which at 3pt wide is not
/// something you can see.
final class MotionStreakNode: SKNode {

    /// `streakWithFade:0.5` — how long a point takes to fade to nothing.
    private static let fadeDuration: TimeInterval = 0.5
    /// `minSeg:10` — a new point is only laid down once the touch has travelled
    /// this far, so a stationary finger does not pile up geometry.
    private static let minimumSegment: CGFloat = 10
    /// `width:3` — the stroke's thickness.
    private static let strokeWidth: CGFloat = 3

    private let texture: SKTexture?
    private var lastPoint: CGPoint?

    override init() {
        // `SpriteLibrary` reports points at 2x, but streak3.png only ever
        // shipped at 1x, so its texture is taken raw and every segment is sized
        // explicitly from the stroke width instead.
        texture = SpriteLibrary.image(named: "streak3")?.texture
        super.init()
        zPosition = ZOrder.streak
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    /// Moves the head of the stroke. The first call after a `reset()` only
    /// plants the anchor: cocos2d's `startingPositionInitialized_` guard meant
    /// the streak never drew a segment from wherever it happened to be last.
    func extend(to point: CGPoint) {
        defer { lastPoint = point }
        guard let from = lastPoint else { return }

        let dx = point.x - from.x
        let dy = point.y - from.y
        let length = (dx * dx + dy * dy).squareRoot()
        guard length >= Self.minimumSegment else {
            lastPoint = from
            return
        }

        addSegment(from: from, dx: dx, dy: dy, length: length)
    }

    private func addSegment(from: CGPoint, dx: CGFloat, dy: CGFloat, length: CGFloat) {
        let segment: SKSpriteNode
        if let texture {
            segment = SKSpriteNode(texture: texture)
        } else {
            segment = SKSpriteNode(color: .white, size: .zero)
        }
        // streak3.png is a 2x10 strip whose long axis runs *across* the sprite's
        // height, so the quad is built tall and then rotated onto the segment.
        segment.size = CGSize(width: Self.strokeWidth, height: length)
        segment.color = .white
        segment.colorBlendFactor = 0
        segment.blendMode = .alpha
        segment.position = CGPoint(x: from.x + dx / 2, y: from.y + dy / 2)
        segment.zRotation = atan2(dy, dx) - .pi / 2
        addChild(segment)

        // `pointState_` decays linearly, so a plain fade matches it.
        segment.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: Self.fadeDuration),
            SKAction.removeFromParent(),
        ]))
    }

    /// Drops the stroke's anchor so the next `extend(to:)` starts a fresh line
    /// rather than whipping one across the screen. Segments already laid down
    /// keep fading out on their own, exactly as they did when you lifted your
    /// finger in the original.
    func reset() {
        lastPoint = nil
    }
}

import SpriteKit

/// The one-screen tutorial cards the original showed at the start of certain
/// levels, ported from `UILayer.m:158-269`.
///
/// Each was a full-bleed `tip-world-<W>-level-<L>.png` sprite with a `tip-ok`
/// button parked at `ccp(tip.contentSize.width/2, 27)` that did nothing but set
/// `tip.visible = NO`.
enum LevelTip {

    /// The nine (world, level) pairs `UILayer.m` had a card for. There is no
    /// pattern to them; this is the authored list.
    private static let levels: Set<[Int]> = [
        [1, 1], [1, 2], [1, 3], [1, 5], [1, 17],
        [2, 1],
        [3, 9],
        [4, 1], [4, 9],
    ]

    /// The image for a level, if it has one.
    ///
    /// `UILayer.m:158` wrapped every card in `if ( !game.isRestart )`, so a
    /// replay after dying goes straight into the level. That is the *only*
    /// gate: unlike the store's "Good News!" tip there is no seen-once flag, so
    /// a fresh attempt shows the card again. Reproduced as-is — these are short
    /// mechanical reminders tied to the level you are about to play, not
    /// one-time news, and the original's authors clearly wanted them repeated.
    static func imageName(world: Int, level: Int, isRestart: Bool) -> String? {
        guard !isRestart, levels.contains([world, level]) else { return nil }
        return "tip-world-\(world)-level-\(level)"
    }
}

/// A single tip card plus its OK button.
final class LevelTipNode: SKNode {

    /// The name given to the OK button so the scene can hit-test it.
    static let dismissName = "tip.ok"

    private let card: SKSpriteNode
    private var okButton: SKSpriteNode?

    init?(imageName: String) {
        guard let image = SpriteLibrary.image(named: imageName) else { return nil }
        card = SKSpriteNode(texture: image.texture, size: image.size)
        super.init()
        zPosition = ZOrder.overlay
        addChild(card)

        if let ok = SpriteLibrary.image(named: "tip-ok") {
            let button = SKSpriteNode(texture: ok.texture, size: ok.size)
            // `UILayer.m` positioned the button 27pt up from the card's bottom
            // edge, horizontally centred.
            button.position = CGPoint(x: 0, y: -card.size.height / 2 + 27)
            button.name = Self.dismissName
            card.addChild(button)
            okButton = button
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    /// Keeps the card on screen on short devices. The art is 268x348 authored
    /// points; anything narrower or shorter than that plus a margin scales it
    /// down rather than letting it bleed off the edge.
    func layout(sceneSize: CGSize) {
        let margin: CGFloat = 24
        let fit = min(
            1,
            min(
                (sceneSize.width - margin) / card.size.width,
                (sceneSize.height - margin) / card.size.height
            )
        )
        setScale(fit)
        position = .zero
    }

    /// Whether a point in the *parent's* coordinate space lands on the card.
    /// Taps anywhere on the card dismiss it, not just the OK button — the
    /// button is small, and there is nothing else the card can do.
    func coversPoint(_ point: CGPoint) -> Bool {
        calculateAccumulatedFrame().contains(point)
    }
}

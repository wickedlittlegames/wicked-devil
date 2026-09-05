import SpriteKit
import WickedDevilCore

/// The in-game HUD, ported from `UILayer.m`.
///
/// The original drew a `bg-topbar.png` strip across the top with the world and
/// level number in the middle, three big-collectable slots on the left, and no
/// live score readout. This adds the souls counter and the level clock the
/// modern layout has room for, and keeps the original's pop-in animation when a
/// big collectable is banked.
final class HUDNode: SKNode {

    private let topBar = SKSpriteNode()
    private let levelLabel = SKLabelNode()
    private let soulsLabel = SKLabelNode()
    private let timeLabel = SKLabelNode()
    private var bigCollectableIcons: [SKSpriteNode] = []

    /// Width of the 320pt design space the HUD is laid out against.
    private let designWidth: CGFloat = 320

    private var lastSouls = -1
    private var lastTime = -1
    private var shownBigCollectables = 0

    init(game: Game, sceneSize: CGSize, topInset: CGFloat) {
        super.init()
        zPosition = ZOrder.hud
        build(game: game, sceneSize: sceneSize, topInset: topInset)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    private func build(game: Game, sceneSize: CGSize, topInset: CGFloat) {
        let fontName = GameFont.preferredName
        let barName = game.isDetectiveLevel ? "bg-topbar-bw" : "bg-topbar"
        // The HUD is a child of the camera, so its origin is the screen centre.
        let barY = sceneSize.height / 2 - topInset - 15

        if let bar = SpriteLibrary.image(named: barName) {
            topBar.texture = bar.texture
            topBar.size = CGSize(width: designWidth, height: bar.size.height)
            topBar.position = CGPoint(x: 0, y: barY)
            addChild(topBar)
        }

        levelLabel.fontName = fontName
        levelLabel.fontSize = 24
        levelLabel.fontColor = .black
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.text = "\(game.world) - \(game.level)"
        levelLabel.position = CGPoint(x: 0, y: barY)
        addChild(levelLabel)

        soulsLabel.fontName = fontName
        soulsLabel.fontSize = 18
        soulsLabel.fontColor = .black
        soulsLabel.verticalAlignmentMode = .center
        soulsLabel.horizontalAlignmentMode = .right
        soulsLabel.position = CGPoint(x: designWidth / 2 - 12, y: barY + 6)
        addChild(soulsLabel)

        timeLabel.fontName = fontName
        timeLabel.fontSize = 14
        timeLabel.fontColor = .black
        timeLabel.verticalAlignmentMode = .center
        timeLabel.horizontalAlignmentMode = .right
        timeLabel.position = CGPoint(x: designWidth / 2 - 12, y: barY - 10)
        addChild(timeLabel)

        let iconName = game.isDetectiveLevel ? "icon-bigcollectable-bw" : "icon-bigcollectable"
        for index in 0..<3 {
            let x = -designWidth / 2 + 15 + CGFloat(index) * 30
            if let empty = SpriteLibrary.image(named: "icon-bigcollectable-empty") {
                let node = SKSpriteNode(texture: empty.texture, size: empty.size)
                node.position = CGPoint(x: x, y: barY)
                addChild(node)
            }
            if let filled = SpriteLibrary.image(named: iconName) {
                let node = SKSpriteNode(texture: filled.texture, size: filled.size)
                node.position = CGPoint(x: x, y: barY)
                node.isHidden = true
                addChild(node)
                bigCollectableIcons.append(node)
            }
        }
    }

    /// `UILayer update:` — reveals the next big-collectable icon with the
    /// original quarter-second scale-in.
    func update(game: Game) {
        let player = game.player

        if player.collected != lastSouls {
            lastSouls = player.collected
            soulsLabel.text = "SOULS \(player.collected)"
        }

        if player.time != lastTime {
            lastTime = player.time
            let remaining = max(0, game.timeLimit - player.time)
            timeLabel.text = "TIME \(remaining)"
            timeLabel.fontColor = remaining == 0 ? .red : .black
        }

        while shownBigCollectables < min(player.bigCollected, bigCollectableIcons.count) {
            let icon = bigCollectableIcons[shownBigCollectables]
            shownBigCollectables += 1
            icon.isHidden = false
            icon.xScale = 0
            icon.run(SKAction.scaleX(to: 1, duration: 0.25))
        }
    }
}

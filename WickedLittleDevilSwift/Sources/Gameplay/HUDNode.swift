import SpriteKit
import WickedDevilCore

/// The in-game HUD, ported from `UILayer.m`.
///
/// The original drew a `bg-topbar.png` strip across the top with the world and
/// level number in the middle, three big-collectable slots on the left, and no
/// live score readout. This adds the souls counter and the level clock the
/// modern layout has room for, and keeps the original's pop-in animation when a
/// big collectable is banked.
///
/// `UILayer.m` pinned the bar to `screenSize.height - 16`, i.e. hard against
/// the top edge. On a device with a Dynamic Island that would put the level
/// number under the cutout, so the bar is pushed down by the top safe-area
/// inset instead — the same "16pt from the top of the usable screen" rule, just
/// measured from where the usable screen now starts.
final class HUDNode: SKNode {

    private let topBar = SKSpriteNode()
    private let levelLabel = SKLabelNode()
    private let soulsLabel = SKLabelNode()
    private let timeLabel = SKLabelNode()
    private var emptyIcons: [SKSpriteNode] = []
    private var bigCollectableIcons: [SKSpriteNode] = []
    private let pauseButton = SKNode()
    private var pauseHitArea = SKSpriteNode()

    /// Width of the 320pt design space the HUD is laid out against. The bar
    /// stays this wide even on an iPad, so it frames the play column rather
    /// than stretching across scenery the player cannot reach.
    private let designWidth = GameplayLayout.designWidth

    private var lastSouls = -1
    private var lastTime = -1
    private var shownBigCollectables = 0

    init(game: Game) {
        super.init()
        zPosition = ZOrder.hud
        build(game: game)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    private func build(game: Game) {
        let fontName = GameFont.preferredName
        let barName = game.isDetectiveLevel ? "bg-topbar-bw" : "bg-topbar"

        if let bar = SpriteLibrary.image(named: barName) {
            topBar.texture = bar.texture
            topBar.size = CGSize(width: designWidth, height: bar.size.height)
            addChild(topBar)
        }

        levelLabel.fontName = fontName
        levelLabel.fontSize = 24
        levelLabel.fontColor = .black
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.text = "\(game.world) - \(game.level)"
        addChild(levelLabel)

        soulsLabel.fontName = fontName
        soulsLabel.fontSize = 18
        soulsLabel.fontColor = .black
        soulsLabel.verticalAlignmentMode = .center
        soulsLabel.horizontalAlignmentMode = .right
        addChild(soulsLabel)

        timeLabel.fontName = fontName
        timeLabel.fontSize = 14
        timeLabel.fontColor = .black
        timeLabel.verticalAlignmentMode = .center
        timeLabel.horizontalAlignmentMode = .right
        addChild(timeLabel)

        let iconName = game.isDetectiveLevel ? "icon-bigcollectable-bw" : "icon-bigcollectable"
        for _ in 0..<3 {
            if let empty = SpriteLibrary.image(named: "icon-bigcollectable-empty") {
                let node = SKSpriteNode(texture: empty.texture, size: empty.size)
                addChild(node)
                emptyIcons.append(node)
            }
            if let filled = SpriteLibrary.image(named: iconName) {
                let node = SKSpriteNode(texture: filled.texture, size: filled.size)
                node.isHidden = true
                addChild(node)
                bigCollectableIcons.append(node)
            }
        }

        buildPauseButton()
    }

    /// `UILayer.m:51-57` put two `CCMenuItemImage`s in the top right — one
    /// reloading the level, one opening the pause overlay — at
    /// `ccp(width - 48, height - 16)`.
    ///
    /// Only one button survives here. Both of the original's were live during
    /// play, and an unguarded restart a thumb's width from the pause control is
    /// a bad trade on a game about not dying; restart moves inside the menu
    /// instead.
    ///
    /// The one that survives is the original's pause control. Its two files are
    /// misleadingly named: `btn-pause.png` draws a reload glyph and is wired to
    /// `tap_reload`, while `btn-gameplay-menu.png` draws the word MENU and is
    /// the one wired to `tap_pause`. We keep the artwork with the behaviour.
    private func buildPauseButton() {
        pauseButton.name = HUDNode.pauseButtonName
        pauseButton.zPosition = 1

        // The icon is well under the 44pt minimum touch target, so an invisible
        // pad carries the taps.
        pauseHitArea = SKSpriteNode(color: .clear, size: CGSize(width: 60, height: 48))
        pauseHitArea.name = HUDNode.pauseButtonName
        pauseButton.addChild(pauseHitArea)

        if let icon = SpriteLibrary.image(named: "btn-gameplay-menu") {
            let sprite = SKSpriteNode(texture: icon.texture, size: icon.size)
            sprite.name = HUDNode.pauseButtonName
            pauseButton.addChild(sprite)
        }
        addChild(pauseButton)
    }

    static let pauseButtonName = "hud.pause"

    /// Whether a point in the HUD's coordinate space hits the pause button.
    func isPauseButton(at point: CGPoint) -> Bool {
        pauseButton.calculateAccumulatedFrame().contains(point)
    }

    /// Positions everything for the current scene size and safe area. Safe to
    /// call repeatedly; the scene calls it whenever either changes.
    func layout(sceneSize: CGSize, safeArea: SafeAreaInsets) {
        // The HUD is a child of the camera, so its origin is the screen centre.
        let barY = sceneSize.height / 2 - safeArea.top - HUDNode.barCentreFromTop

        topBar.position = CGPoint(x: 0, y: barY)
        levelLabel.position = CGPoint(x: 0, y: barY)
        soulsLabel.position = CGPoint(x: designWidth / 2 - 12, y: barY + 6)
        timeLabel.position = CGPoint(x: designWidth / 2 - 12, y: barY - 10)

        for (index, node) in emptyIcons.enumerated() {
            node.position = CGPoint(x: iconX(index), y: barY)
        }
        for (index, node) in bigCollectableIcons.enumerated() {
            node.position = CGPoint(x: iconX(index), y: barY)
        }

        // Tucked under the right end of the bar rather than on it: the bar's
        // right-hand side already carries the souls and clock readouts.
        pauseButton.position = CGPoint(
            x: designWidth / 2 - 26,
            y: barY - topBar.size.height / 2 - 24
        )
    }

    private func iconX(_ index: Int) -> CGFloat {
        -designWidth / 2 + 15 + CGFloat(index) * 30
    }

    /// `UILayer.m` placed the bar's contents at `screenSize.height - 16`.
    private static let barCentreFromTop: CGFloat = 15

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

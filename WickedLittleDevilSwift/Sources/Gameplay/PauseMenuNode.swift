import SpriteKit
import WickedDevilCore

/// The in-game pause menu, ported from the overlay in `UILayer.m:85-139`.
///
/// The original built it from a fixed 320x480 `bg-pauseoverlay.png` with
/// `CCLabelTTF` menu items laid over it — `RESUME GAME`, `BACK TO LEVEL
/// SELECT`, and read-only lines showing the best score, the level number and
/// the equipped powerup. That background cannot stretch to a modern aspect
/// ratio without distorting, so the panel is drawn rather than blitted; the
/// text, the colour (`ccc3(205,51,51)`) and the wording are the original's.
///
/// One addition: `RESTART LEVEL`. The original had a separate always-on
/// restart button in the top bar (`UILayer.m:51`, wired to `tap_reload`), which
/// is a hair-trigger thing to leave live during play, so it moves in here
/// beside the other two.
final class PauseMenuNode: SKNode {

    enum Action: String {
        case resume = "pause.resume"
        case restart = "pause.restart"
        case quit = "pause.quit"
    }

    /// `UILayer.m:91` — `ccc3(205,51,51)`.
    private static let inkColour = UIColor(red: 205 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)

    private let dim = SKSpriteNode(color: .black, size: .zero)
    private let panel = SKShapeNode()
    private let content = SKNode()
    private var buttons: [(node: SKNode, action: Action)] = []

    private static let panelWidth: CGFloat = 260

    init(game: Game) {
        super.init()
        build(game: game)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    private func build(game: Game) {
        dim.alpha = 0.55
        dim.zPosition = ZOrder.pauseDim
        addChild(dim)

        content.zPosition = ZOrder.pauseMenu
        addChild(content)

        panel.fillColor = UIColor(white: 0.06, alpha: 0.92)
        panel.strokeColor = Self.inkColour
        panel.lineWidth = 2
        content.addChild(panel)

        var y: CGFloat = 0
        let title = label("PAUSED", size: 34, colour: .white)
        content.addChild(title)

        // `UILayer.m:92-94` printed the level number, the best score for it and
        // the powerup you went in with.
        let user = game.user
        let detail = [
            "\(game.world) - \(game.level)",
            "BEST: \(user?.highscore(world: game.world, level: game.level) ?? 0)",
            "POWERUP: \(Self.equippedName(for: user)?.uppercased() ?? "NONE")",
        ]
        var detailLabels: [SKLabelNode] = []
        for line in detail {
            let node = label(line, size: 13, colour: UIColor(white: 0.75, alpha: 1))
            content.addChild(node)
            detailLabels.append(node)
        }

        let actions: [(String, Action)] = [
            ("RESUME GAME", .resume),
            ("RESTART LEVEL", .restart),
            ("BACK TO LEVEL SELECT", .quit),
        ]
        var actionRows: [SKNode] = []
        for (text, action) in actions {
            let row = button(text: text, action: action)
            content.addChild(row)
            actionRows.append(row)
        }

        // Lay out top-down from the panel's centre.
        let titleGap: CGFloat = 30
        let detailGap: CGFloat = 20
        let buttonGap: CGFloat = 38
        let height = titleGap + CGFloat(detail.count) * detailGap + 12
            + CGFloat(actions.count) * buttonGap + 24
        panel.path = CGPath(
            roundedRect: CGRect(x: -Self.panelWidth / 2, y: -height / 2, width: Self.panelWidth, height: height),
            cornerWidth: 12,
            cornerHeight: 12,
            transform: nil
        )

        y = height / 2 - 26
        title.position = CGPoint(x: 0, y: y)
        y -= titleGap
        for node in detailLabels {
            node.position = CGPoint(x: 0, y: y)
            y -= detailGap
        }
        y -= 12
        for row in actionRows {
            row.position = CGPoint(x: 0, y: y - buttonGap / 2 + 6)
            y -= buttonGap
        }
    }

    private func label(_ text: String, size: CGFloat, colour: UIColor) -> SKLabelNode {
        let node = SKLabelNode(text: text)
        node.fontName = GameFont.preferredName
        node.fontSize = size
        node.fontColor = colour
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        return node
    }

    private func button(text: String, action: Action) -> SKNode {
        let row = SKNode()
        row.name = action.rawValue

        // A generous invisible target: the glyphs themselves are a thin strip
        // and Apple's 44pt minimum is not negotiable on a pause menu.
        let target = SKSpriteNode(color: .clear, size: CGSize(width: Self.panelWidth - 16, height: 36))
        target.name = action.rawValue
        row.addChild(target)

        let caption = label(text, size: 18, colour: Self.inkColour)
        caption.name = action.rawValue
        row.addChild(caption)

        buttons.append((row, action))
        return row
    }

    /// Which button, if any, sits under a point given in this node's coordinates.
    func action(at point: CGPoint) -> Action? {
        for (node, action) in buttons where node.calculateAccumulatedFrame().contains(point) {
            return action
        }
        return nil
    }

    func layout(sceneSize: CGSize) {
        dim.size = sceneSize
        // Nudged up a little, like `pause_screen`'s `height/2 - 75` offset, so
        // the panel does not sit on the home indicator.
        content.position = CGPoint(x: 0, y: 12)
    }

    private static func equippedName(for user: User?) -> String? {
        guard let user, user.boughtPowerups else { return nil }
        if user.powerup >= MenuCatalog.specialPowerupOffset {
            let index = user.powerup - MenuCatalog.specialPowerupOffset
            return MenuCatalog.specialPowerups.first { $0.index == index }?.name
        }
        return MenuCatalog.powerups.first { $0.index == user.powerup }?.name
    }
}

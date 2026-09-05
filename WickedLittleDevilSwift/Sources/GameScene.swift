import SpriteKit

final class GameScene: SKScene {
    private let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.11, green: 0.05, blue: 0.16, alpha: 1.0)

        if titleLabel.parent == nil {
            titleLabel.text = "Wicked Little Devil"
            titleLabel.fontSize = 28
            titleLabel.fontColor = .white
            titleLabel.verticalAlignmentMode = .center
            titleLabel.horizontalAlignmentMode = .center
            addChild(titleLabel)
        }

        updateLayout()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        updateLayout()
    }

    private func updateLayout() {
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}

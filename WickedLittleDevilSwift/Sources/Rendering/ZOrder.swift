import SpriteKit
import WickedDevilCore

/// Draw order for the gameplay scene, mirroring the original layer stack:
/// `BGLayer` behind, then the game layer, FX, the player, and `UILayer` on top.
enum ZOrder {
    static let background: CGFloat = -100
    static let trigger: CGFloat = 1
    static let platform: CGFloat = 10
    static let collectable: CGFloat = 20
    static let enemy: CGFloat = 30
    static let projectile: CGFloat = 35
    static let effects: CGFloat = 40
    static let player: CGFloat = 50
    static let hud: CGFloat = 100
    static let overlay: CGFloat = 200
}

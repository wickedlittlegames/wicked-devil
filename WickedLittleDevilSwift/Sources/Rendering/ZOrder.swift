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
    /// The touch trail. `GameScene.m` added the streak to the scene after
    /// `layer_ui`, both at z 0, so it actually drew over the HUD; it sits under
    /// the top bar here so a flick across the score cannot smear it.
    static let streak: CGFloat = 60
    /// The pause dim deliberately sits *below* the HUD: the original's
    /// `bg-pauseoverlay` covered the top bar, but the score and clock are worth
    /// being able to read while you decide whether to restart.
    static let pauseDim: CGFloat = 90
    static let hud: CGFloat = 100
    static let overlay: CGFloat = 200
    /// Pause menu furniture, above the HUD it is dimming.
    static let pauseMenu: CGFloat = 210
}

import SpriteKit
import WickedDevilCore

/// The devil sprite.
///
/// `Player.m` ran four `CCAnimate` actions off a per-character spritesheet:
/// jump / fall / fall-far at 0.05s a frame and the death animation at 0.01s a
/// frame spawned with a half-second fade. Those are rebuilt here as
/// `SKAction`s; the *state* still lives in `WickedDevilCore.Player`.
final class PlayerNode: SKSpriteNode {

    private enum Timing {
        static let frame = 0.05
        static let deathFrame = 0.01
        static let deathFade = 0.5
    }

    private enum ActionKey {
        static let animation = "player-animation"
    }

    private var animations: [PlayerAnimation: SKAction] = [:]
    private var lastAnimation: PlayerAnimation = .none

    init(atlasName: String, contentSize: CGSize) {
        let atlas = SpriteAtlas.named(atlasName) ?? SpriteAtlas.named(PlayerCharacter.defaultAtlasName)
        let first = atlas?.frame("jump1.png")
        super.init(
            texture: first?.texture,
            color: .clear,
            size: first?.size ?? contentSize
        )
        zPosition = ZOrder.player
        buildAnimations(from: atlas)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    private func buildAnimations(from atlas: SpriteAtlas?) {
        guard let atlas else { return }

        func animate(_ prefix: String, timePerFrame: TimeInterval) -> SKAction? {
            let frames = atlas.animationFrames(prefix: prefix, count: 6)
            guard !frames.isEmpty else { return nil }
            // cocos2d swapped the sprite frame *and* its content size each step
            // while keeping the 0.5/0.5 anchor. `SKAction.animate(resize:)`
            // can't be used for that because the textures are cut from the
            // retina sheet, so it would size every frame in pixels rather than
            // points; each step therefore applies the authored point size.
            let steps = frames.flatMap { frame in
                [
                    SKAction.run { [weak self] in
                        self?.texture = frame.texture
                        self?.size = frame.size
                    },
                    SKAction.wait(forDuration: timePerFrame),
                ]
            }
            return SKAction.sequence(steps)
        }

        animations[.jump] = animate("jump", timePerFrame: Timing.frame)
        animations[.fall] = animate("fall", timePerFrame: Timing.frame)
        animations[.fallFar] = animate("fall_far", timePerFrame: Timing.frame)
        if let die = animate("die", timePerFrame: Timing.deathFrame) {
            animations[.die] = SKAction.group([die, SKAction.fadeOut(withDuration: Timing.deathFade)])
        }
    }

    // MARK: - Driving the animation state machine

    /// Restarts the jump animation, calling `endAnimation()` when it finishes
    /// exactly like the original's `CCCallFunc` completion.
    func playJump(for player: Player) {
        run(animation: .jump) { [weak player] in player?.endAnimation() }
    }

    /// Mirrors whatever animation the domain layer latched this frame.
    func syncAnimation(with player: Player) {
        guard player.animation != lastAnimation else { return }
        switch player.animation {
        case .fall, .fallFar, .die:
            run(animation: player.animation, completion: nil)
        case .jump, .none:
            // Jumps are driven by `playerJumped` events so a bounce restarts the
            // animation even when the previous one is still running.
            lastAnimation = player.animation
        }
    }

    private func run(animation: PlayerAnimation, completion: (() -> Void)?) {
        guard let action = animations[animation] else { return }
        lastAnimation = animation
        removeAction(forKey: ActionKey.animation)
        if let completion {
            run(SKAction.sequence([action, SKAction.run(completion)]), withKey: ActionKey.animation)
        } else {
            run(action, withKey: ActionKey.animation)
        }
    }

    /// Resets the sprite for a fresh run.
    func reset() {
        removeAction(forKey: ActionKey.animation)
        alpha = 1
        lastAnimation = .none
    }
}

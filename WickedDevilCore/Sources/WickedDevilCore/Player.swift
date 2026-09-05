import Foundation

/// Which visual state the player is in. The original `Player` ran cocos2d
/// `CCAnimate` actions; the domain layer only tracks *which* animation should be
/// playing so the SpriteKit layer can drive the actual frames.
public enum PlayerAnimation: Int, Codable, Sendable, CaseIterable {
    case none = 0
    /// `animate:1`
    case jump = 1
    /// `animate:2` — short fall
    case fall = 2
    /// `animate:3` — long fall
    case fallFar = 3
    /// `animate:4` — death (played with a fade-out in the original)
    case die = 4
}

/// Playable characters, mirroring `Player setupCharacter:`.
public enum PlayerCharacter: Int, Codable, Sendable, CaseIterable {
    case detective = 0
    case pixel = 1
    case zombie = 2
    case ninja = 3
    case pirate = 4
    case angel = 5

    /// The sprite sheet the rendering layer should load. Kept here (rather than
    /// in the renderer) because the mapping is part of the ported game data.
    public var animationAtlasName: String {
        switch self {
        case .detective: return "AnimDetectiveDevil"
        case .pixel: return "PixelAnimDevil"
        case .zombie: return "ZombieAnimDevil"
        case .ninja: return "NinjaAnimDevil"
        case .pirate: return "PirateAnimDevil"
        case .angel: return "AngelAnimDevil"
        }
    }

    /// The default devil used when the player has not bought a character.
    public static let defaultAtlasName = "AnimDevil"
}

/// Powerup identifiers used by `Player setupPowerup:` and the shop scenes.
/// IDs >= 100 came from `Powerups_special.plist`, the rest from `Powerups.plist`.
public enum Powerup: Int, Codable, Sendable, CaseIterable {
    case none = 0
    case bouncyDevilI = 4
    case bouncyDevilII = 5
    case bouncyDevilIII = 6
    case featherDevilI = 7
    case featherDevilII = 8
    case featherDevilIII = 9
    case quickDevilI = 10
    case quickDevilII = 11
    case quickDevilIII = 12
    case toughDevilI = 13
    case toughDevilII = 14
    case toughDevilIII = 15
    case toughDevilIV = 16
    case winningDevilI = 17
    case winningDevilII = 18
    case winningDevilIII = 19
    case richDevilI = 20
    case richDevilII = 21
    case richDevilIII = 22
    /// Platforms are never culled while this is equipped (`GameLayer.m`).
    case boundPlatform = 100
    case bubblePop = 101
    /// Small collectables within an 80pt radius drift towards the player.
    case magnetSoul = 102
    /// Small collectables within a 140pt radius drift towards the player.
    case magnetSoulPlus = 103
    /// Rocket launchers do not fire while this is equipped.
    case dud = 104
    case detectiveOutfit = 105

    /// Radius used by the two magnet powerups (`Collectable.m radiusCheck`).
    public var magnetRadius: Double? {
        switch self {
        case .magnetSoul: return 80
        case .magnetSoulPlus: return 140
        default: return nil
        }
    }
}

/// The player, ported from `Objects/Player.h` / `Player.m`.
///
/// This is a custom kinematic platformer: position/velocity/gravity are
/// integrated by hand once per frame, so the maths ports over unchanged. All
/// `CCSprite` inheritance has been replaced by plain position/size/scale data.
public final class Player {

    // MARK: - Transform

    public var position: Vec2
    /// Unscaled content size. `Platform.intersectCheck` uses the *unscaled*
    /// content size, while `worldBoundingBox` applies `scale`.
    public var contentSize: SizeF
    /// `Player.m` init: `self.scale = 1.25`.
    public var scale: Double

    // MARK: - Physics

    public var velocity: Vec2
    public var health: Double
    /// Damage dealt to breakable platforms; halved/thirded/quartered by the
    /// Feather Devil powerups.
    public var damage: Double
    public var jumpSpeed: Double
    public var gravity: Double
    /// Extra gravity layered on top of `gravity` (used by level modifiers).
    public var modifierGravity: Double
    /// Maximum horizontal movement per frame when following the touch point.
    public var drag: Double

    // MARK: - Run counters

    public var collected: Int
    public var bigCollected: Int
    public var haloCollected: Int
    public var score: Int
    /// Whole seconds elapsed; incremented once per second by the game clock.
    public var time: Int
    public var jumps: Int
    public var deaths: Int
    /// Score awarded per small collectable (raised by Winning Devil).
    public var perCollectable: Int
    /// Small collectables counted per pickup (raised by Rich Devil).
    public var collectableMultiplier: Int

    // MARK: - State

    /// Identity of the last platform landed on, replacing the original's
    /// `id last_platform_touched`.
    public var lastPlatformTouchedID: String?
    public var controllable: Bool
    /// Flip-flop used by toggle-switch platforms (tags 5 / 51 / 52).
    public var toggledPlatform: Bool
    /// True while an animation "owns" the player; `animate:` is a no-op then.
    public var animating: Bool
    public var falling: Bool
    /// True while a bubble is carrying the player upwards.
    public var floating: Bool
    public private(set) var animation: PlayerAnimation
    public var character: PlayerCharacter?
    /// Sprite sheet the renderer should use, updated by `setupCharacter`.
    public private(set) var animationAtlasName: String
    /// The powerup applied by `setupPowerup(_:)`; the world reads it for the
    /// magnet radius and the platform-binding / dud-rocket rules.
    public private(set) var equippedPowerup: Powerup

    public let device: DeviceProfile

    public init(
        position: Vec2 = .zero,
        contentSize: SizeF = Player.defaultContentSize,
        device: DeviceProfile = .standard
    ) {
        self.position = position
        self.contentSize = contentSize
        self.device = device
        self.velocity = .zero
        self.drag = 4
        self.perCollectable = 10
        self.collectableMultiplier = 1
        self.scale = 1.25
        self.jumpSpeed = device.jumpSpeed
        self.gravity = device.gravity
        self.modifierGravity = 0
        self.health = 1.0
        self.damage = 1.0
        self.collected = 0
        self.bigCollected = 0
        self.score = 0
        self.time = 0
        self.jumps = 0
        self.deaths = 0
        self.haloCollected = 0
        self.lastPlatformTouchedID = nil
        self.controllable = false
        self.toggledPlatform = false
        self.animating = false
        self.falling = false
        self.floating = false
        self.animation = .none
        self.character = nil
        self.animationAtlasName = PlayerCharacter.defaultAtlasName
        self.equippedPowerup = .none
    }

    /// Size of the devil sprite frames in `AnimDevil.plist`.
    public static let defaultContentSize = SizeF(width: 28, height: 35)

    /// Equivalent of cocos2d's `worldBoundingBox`, which applies the node
    /// transform (including `scale`) to the content-size rect.
    public var boundingBox: RectF {
        RectF.centered(
            at: position,
            size: SizeF(width: contentSize.width * scale, height: contentSize.height * scale)
        )
    }

    public var isAlive: Bool { health > 0.0 }

    public var isControllable: Bool { controllable }

    // MARK: - Integration

    /// One frame of vertical integration, ported verbatim from `Player move`.
    ///
    /// Horizontal motion is *not* applied here: the original moved the player
    /// horizontally in `GameScene control_player`, see `applyHorizontalControl`.
    public func move() {
        velocity.y -= (gravity + modifierGravity)
        position.y += velocity.y

        if velocity.y < 0 && velocity.y > -5 {
            falling = false
            animate(.fall)
        }

        if velocity.y < -8.5 && !falling {
            falling = true
            animate(.fallFar)
        }
    }

    /// `Player jump:` — sets the vertical velocity directly and restarts the
    /// jump animation.
    public func jump(_ speed: Double) {
        animating = false
        animate(.jump)
        velocity.y = speed
    }

    /// `GameScene control_player` — moves the player towards the touch X,
    /// clamped to +/- `drag` per frame.
    public func applyHorizontalControl(towardX targetX: Double) {
        guard controllable else { return }
        var diff = targetX - position.x
        if diff > drag { diff = drag }
        if diff < -drag { diff = -drag }
        position.x += diff
    }

    // MARK: - Animation state machine

    /// `Player animate:` — only takes effect when no animation is running.
    public func animate(_ animation: PlayerAnimation) {
        guard !animating else { return }
        animating = true
        self.animation = animation
    }

    /// `Player end_animate` — the renderer calls this when the current
    /// animation finishes. In the original only the jump animation had this
    /// callback attached; fall/die animations stayed latched.
    public func endAnimation() {
        animating = false
    }

    /// Convenience used by enemies/hazards: force-restart the death animation.
    public func playDeathAnimation() {
        animating = false
        animate(.die)
    }

    // MARK: - Setup

    /// `Player setupCharacter:` — in the original this swapped sprite sheets.
    public func setupCharacter(_ character: PlayerCharacter) {
        self.character = character
        self.animationAtlasName = character.animationAtlasName
    }

    /// `Player setupPowerup:` — applies the equipped powerup's stat changes.
    /// Unknown IDs are ignored, matching the original `default: break`.
    public func setupPowerup(_ powerup: Powerup) {
        equippedPowerup = powerup
        switch powerup {
        case .bouncyDevilI:
            jumpSpeed += 0.5
        case .bouncyDevilII:
            jumpSpeed += 1.0
        case .bouncyDevilIII:
            jumpSpeed += 1.5
        case .featherDevilI:
            damage = damage / 2
        case .featherDevilII:
            damage = damage / 3
        case .featherDevilIII:
            damage = damage / 4
        case .quickDevilI:
            drag = 4.5
        case .quickDevilII:
            drag = 4.75
        case .quickDevilIII:
            drag = 5.5
        case .toughDevilI:
            health += 1
        case .toughDevilII:
            health += 2
        case .toughDevilIII:
            health += 3
        case .toughDevilIV:
            health += 1000
        case .winningDevilI:
            perCollectable = 15
        case .winningDevilII:
            perCollectable = 20
        case .winningDevilIII:
            perCollectable = 30
        case .richDevilI:
            collectableMultiplier = 2
        case .richDevilII:
            collectableMultiplier = 3
        case .richDevilIII:
            collectableMultiplier = 5
        case .detectiveOutfit:
            setupCharacter(.detective)
        case .none, .boundPlatform, .bubblePop, .magnetSoul, .magnetSoulPlus, .dud:
            break
        }
    }

    /// Convenience overload for raw powerup IDs coming out of `User`.
    public func setupPowerup(rawValue: Int) {
        guard let powerup = Powerup(rawValue: rawValue) else { return }
        setupPowerup(powerup)
    }

    // MARK: - Damage

    /// Applies one point of damage and latches the death animation when the
    /// player runs out of health, matching the enemy/projectile handlers.
    ///
    /// - Note: `Enemy.m` case 2 fell through into case 22 and `GameLayer.m`
    ///   decremented `health` twice on a rocket hit. Both are unintended
    ///   double-decrements, so this port applies exactly one hit.
    @discardableResult
    public func takeHit(_ amount: Double = 1) -> Bool {
        health -= amount
        if health <= 0 {
            playDeathAnimation()
            return true
        }
        return false
    }
}

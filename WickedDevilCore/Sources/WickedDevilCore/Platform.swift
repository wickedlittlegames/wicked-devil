import Foundation

/// Gameplay events produced by the domain layer.
///
/// The original objects played audio, spawned particles and ran cocos2d actions
/// inline. Those side effects are surfaced as events instead so the rendering /
/// audio layer can react without the domain depending on an engine.
public enum GameEvent: Equatable, Sendable {
    /// Player bounced off a platform. `boost` is the jump-speed multiplier used.
    case playerJumped(platformID: String, boost: Double)
    /// A breakable platform ran out of health and started falling.
    case platformBroke(platformID: String)
    /// A toggle switch flipped the 51/52 platform groups.
    case platformsToggled(switchID: String, enabledGroup: Int)
    /// The player reached the finish platform; `didWin` requires a big collectable.
    case levelFinished(platformID: String, didWin: Bool)
    /// A collectable was picked up.
    case collected(id: String, kind: CollectableKind)
    /// The player lost health. `fatal` is true when the hit killed them.
    case playerHit(sourceID: String, fatal: Bool)
    /// An enemy was defeated (bat bounced on, mine detonated, rocket hit).
    case enemyKilled(enemyID: String)
    /// A bubble picked the player up and started carrying them.
    case bubbleGrabbed(enemyID: String)
    /// A bubble was popped by a tap.
    case bubblePopped(enemyID: String)
    /// A rocket launcher fired.
    case rocketFired(enemyID: String, projectileID: String)
    /// A black hole teleported the player.
    case playerTeleported(enemyID: String, destination: Vec2)
    /// The player fell out of the world or ran out of health.
    case gameOver(didWin: Bool)
}

/// Platform types, matching the `legacyTag` mapping in `Objects/Platform.m` and
/// the `kind` strings emitted by `tools/ccbi-converter`.
public enum PlatformKind: String, Codable, Sendable, CaseIterable {
    case normal
    /// Tag 1: 1.95x jump boost (the source comment says 1.75, the code says 1.95).
    case boost
    /// Tags 2 / 22 / 3 / 33: platforms that ping-pong on a fixed path.
    case moving
    /// Tag 5: flips the toggle target groups.
    case `switch`
    /// Tags 51 / 52: alternately enabled/disabled by a switch.
    case toggleTarget
    /// Tag 6: falls away once the player has done enough damage.
    case breakable
    /// Tags 66 / 663: moving *and* breakable.
    case movingBreakable
    /// Tags 7 / 71 / 72 / 73: timed variants (present in the schema, unused in
    /// the shipped levels).
    case timed
    /// Tag 100: the finish platform.
    case goal
    case unknown

    /// Legacy tag -> kind, mirroring `PLATFORM_TAG_MAP` in the converter.
    public static func from(legacyTag: Int?) -> PlatformKind {
        switch legacyTag {
        case nil, -1, 0: return .normal
        case 1: return .boost
        case 2, 22, 3, 33, 67: return .moving
        case 5: return .switch
        case 51, 52: return .toggleTarget
        case 6: return .breakable
        case 66, 663: return .movingBreakable
        case 7, 71, 72, 73: return .timed
        case 100: return .goal
        default: return .unknown
        }
    }

    /// Jump-speed multiplier applied when the player lands (`Platform.m`).
    public var jumpMultiplier: Double {
        switch self {
        case .boost: return 1.95
        case .goal: return 1.5
        default: return 1.0
        }
    }

    /// Breakables lose health equal to `player.damage` on every landing.
    public var isBreakable: Bool {
        self == .breakable || self == .movingBreakable
    }
}

/// A platform, ported from `Objects/Platform.h` / `Platform.m`.
public final class Platform {
    public let id: String
    public var position: Vec2
    public var contentSize: SizeF
    public let kind: PlatformKind
    public let legacyTag: Int?
    /// Movement description decoded from the level JSON, if any. The domain
    /// layer only stores it; the SpriteKit layer runs the actual tween.
    public let motion: NodeMotion?

    public var health: Double
    /// True while this platform's movement is running. Platforms that carry a
    /// `motion` start animating immediately, exactly as `CCBReader` kicked off
    /// their repeat-forever action on load; being hit can stop them.
    public var animating: Bool
    /// Toggle-target platforms that are currently switched off, and broken
    /// platforms, are `dead`.
    public var dead: Bool
    public var visible: Bool
    /// Which toggle group a 51/52 platform belongs to (1 or 2).
    public let toggleGroup: Int?
    /// Big collectables required to actually win on the goal platform.
    public let requiresBigCollectables: Int

    public init(
        id: String,
        position: Vec2,
        contentSize: SizeF,
        kind: PlatformKind,
        legacyTag: Int? = nil,
        motion: NodeMotion? = nil,
        toggleGroup: Int? = nil,
        requiresBigCollectables: Int = 1,
        health: Double = 1.0,
        dead: Bool = false,
        visible: Bool = true
    ) {
        self.id = id
        self.position = position
        self.contentSize = contentSize
        self.kind = kind
        self.legacyTag = legacyTag
        self.motion = motion
        self.toggleGroup = toggleGroup
        self.requiresBigCollectables = requiresBigCollectables
        self.health = health
        self.animating = motion != nil
        self.dead = dead
        self.visible = visible
    }

    public var boundingBox: RectF {
        RectF.centered(at: position, size: contentSize)
    }

    /// `Platform intersectCheck:` — a deliberately loose landing test: the
    /// player must be horizontally within the platform (plus 10pt of slack on
    /// each side) and vertically within a band just above the platform centre.
    ///
    /// The original named the bounds `max_x`/`min_x` the wrong way round; the
    /// maths is preserved exactly.
    public func isPlayerLanding(_ player: Player) -> Bool {
        let leftBound = position.x - contentSize.width / 2 - 10
        let rightBound = position.x + contentSize.width / 2 + 10
        let topBound = position.y + (contentSize.height + player.contentSize.height) / 2 - 4

        return player.position.x > leftBound
            && player.position.x < rightBound
            && player.position.y > position.y
            && player.position.y < topBound
    }

    /// `Platform isIntersectingPlayer:platforms:` — resolves a landing.
    ///
    /// - Parameters:
    ///   - player: the player to bounce.
    ///   - platforms: every platform in the level, needed by the toggle switch.
    /// - Returns: the events produced by the landing (empty when there was none).
    @discardableResult
    public func resolveCollision(with player: Player, platforms: [Platform]) -> [GameEvent] {
        guard visible, !dead, player.velocity.y < 0, isPlayerLanding(player) else { return [] }

        var events: [GameEvent] = []
        player.jumps += 1
        player.lastPlatformTouchedID = id

        switch kind {
        case .breakable, .movingBreakable:
            // 66/663 stop their move action when hit so they can fall away.
            if kind == .movingBreakable { animating = false }
            player.jump(player.jumpSpeed)
            events.append(.playerJumped(platformID: id, boost: 1.0))
            health -= player.damage
            if health <= 0 {
                dead = true
                visible = false
                events.append(.platformBroke(platformID: id))
            }

        case .switch:
            player.jump(player.jumpSpeed)
            events.append(.playerJumped(platformID: id, boost: 1.0))
            events.append(applyToggle(player: player, platforms: platforms))

        case .goal:
            player.jump(player.jumpSpeed * kind.jumpMultiplier)
            events.append(.playerJumped(platformID: id, boost: kind.jumpMultiplier))
            let didWin = player.bigCollected >= requiresBigCollectables
            events.append(.levelFinished(platformID: id, didWin: didWin))

        case .boost:
            player.jump(player.jumpSpeed * kind.jumpMultiplier)
            events.append(.playerJumped(platformID: id, boost: kind.jumpMultiplier))

        case .normal, .moving, .toggleTarget, .timed, .unknown:
            player.jump(player.jumpSpeed)
            events.append(.playerJumped(platformID: id, boost: 1.0))
        }

        return events
    }

    /// `Platform action:` for tag 5 — group 1 (tag 51) and group 2 (tag 52)
    /// swap between alive and dead, then the player's flip-flop inverts.
    private func applyToggle(player: Player, platforms: [Platform]) -> GameEvent {
        for platform in platforms where platform.kind == .toggleTarget {
            switch platform.toggleGroup {
            case 1: platform.dead = !player.toggledPlatform
            case 2: platform.dead = player.toggledPlatform
            default: break
            }
        }
        let enabledGroup = player.toggledPlatform ? 1 : 2
        player.toggledPlatform.toggle()
        return .platformsToggled(switchID: id, enabledGroup: enabledGroup)
    }
}

import Foundation

/// Enemy types, matching the legacy tag comments at the top of `Objects/Enemy.m`
/// and the `kind` strings emitted by `tools/ccbi-converter`.
public enum EnemyKind: String, Codable, Sendable, CaseIterable {
    /// Tags 1 / 101 — patrols horizontally and wraps at the viewport edge.
    case bat
    /// Tags 2 / 22 / 223 — explodes on contact.
    case mine
    /// Tag 3 — carries the player upwards until tapped.
    case bubble
    /// Tag 4 — fires a rocket when the player comes within range.
    case rocketLauncher
    /// Tag 5 — teleports the player to a destination node.
    case blackHole
    /// Tag 6 — periodic area blast.
    case angelLaser
    case unknown

    public static func from(legacyTag: Int?) -> EnemyKind {
        switch legacyTag {
        case 1, 101: return .bat
        case 2, 22, 223: return .mine
        case 3: return .bubble
        case 4: return .rocketLauncher
        case 5: return .blackHole
        case 6: return .angelLaser
        default: return .unknown
        }
    }
}

/// Patrol direction for bats.
public enum PatrolDirection: String, Codable, Sendable {
    case left
    case right

    public var step: Double {
        switch self {
        case .left: return -1
        case .right: return 1
        }
    }
}

/// An enemy, ported from `Objects/Enemy.h` / `Enemy.m`.
public final class Enemy {
    public let id: String
    public var position: Vec2
    public var contentSize: SizeF
    public let kind: EnemyKind
    public let legacyTag: Int?
    /// Bat patrol direction (tag 1 = right, tag 101 = left).
    public let patrolDirection: PatrolDirection?
    /// Ping-pong movement for moving mines (tags 22 / 223).
    public let motion: NodeMotion?
    /// Destination for a black hole teleport.
    public var teleportDestination: Vec2?

    public var visible: Bool
    /// True while a one-shot action (bubble lift, rocket launch) is running.
    public var running: Bool
    public var dead: Bool
    /// True while this bubble is carrying the player.
    public var floating: Bool
    public var animating: Bool
    public private(set) var projectiles: [Projectile]

    /// `Enemy radiusCheck:` uses a fixed 30pt radius (+1) around the enemy.
    public static let proximityRadius: Double = 30
    /// Bat wrap margins from `Enemy move`.
    public static let wrapRightMargin: Double = 40
    public static let wrapLeftEdge: Double = -50
    /// Bat patrol speed, in points per frame.
    public static let patrolSpeedPerFrame: Double = 1

    private var bubbleElapsed: Double = 0
    private var bubbleDuration: Double = 0
    private var bubbleLift: Double = 0
    private var projectileCounter = 0

    public init(
        id: String,
        position: Vec2,
        contentSize: SizeF,
        kind: EnemyKind,
        legacyTag: Int? = nil,
        patrolDirection: PatrolDirection? = nil,
        motion: NodeMotion? = nil,
        teleportDestination: Vec2? = nil,
        visible: Bool = true
    ) {
        self.id = id
        self.position = position
        self.contentSize = contentSize
        self.kind = kind
        self.legacyTag = legacyTag
        self.patrolDirection = patrolDirection
        self.motion = motion
        self.teleportDestination = teleportDestination
        self.visible = visible
        self.running = false
        self.dead = false
        self.floating = false
        self.animating = false
        self.projectiles = []
    }

    public var boundingBox: RectF {
        RectF.centered(at: position, size: contentSize)
    }

    // MARK: - Movement

    /// `Enemy move` — bats step one point per frame and wrap around the screen.
    ///
    /// - Note: the original tag-101 (left-moving) branch tested
    ///   `position.x > -50` before wrapping, which snapped the bat back to the
    ///   right edge on almost every frame. That is clearly a typo for `<`, so
    ///   this port wraps correctly and the bat actually patrols leftwards.
    public func move(viewport: SizeF) {
        guard kind == .bat, let direction = patrolDirection else { return }
        position.x += direction.step * Enemy.patrolSpeedPerFrame

        switch direction {
        case .right:
            if position.x > viewport.width + Enemy.wrapRightMargin {
                position.x = Enemy.wrapLeftEdge
            }
        case .left:
            if position.x < Enemy.wrapLeftEdge {
                position.x = viewport.width + Enemy.wrapRightMargin
            }
        }
    }

    // MARK: - Collision tests

    /// The original used a pixel-perfect `CCRenderTexture` colour-mask test.
    /// That is a rendering concern, so the domain layer approximates it with the
    /// same bounding-box pre-check the original used to gate the pixel test.
    public func isIntersecting(_ player: Player) -> Bool {
        guard visible, !running else { return false }
        return boundingBox.intersects(player.boundingBox)
    }

    /// `Enemy radiusCheck:` — centre-to-centre distance against a 30pt radius.
    public func isWithinProximity(of player: Player) -> Bool {
        position.distance(to: player.position) <= Enemy.proximityRadius + 1
    }

    /// `Enemy isIntersectingTouch:` — only floating bubbles respond to the
    /// touch point. Whether the pop is *allowed* is the world's business:
    /// it needs the Bubble Pop upgrade.
    public func containsTouch(_ point: Vec2) -> Bool {
        visible && floating && kind == .bubble && boundingBox.contains(point)
    }

    // MARK: - Interactions

    /// `Enemy isIntersectingPlayer:` + `action:game:` — resolves whatever this
    /// enemy does to the player this frame.
    @discardableResult
    public func resolveCollision(
        with player: Player,
        device: DeviceProfile = .standard
    ) -> [GameEvent] {
        guard visible, !running, !dead else { return [] }

        switch kind {
        case .bat:
            guard isIntersecting(player) else { return [] }
            return hitByBat(player)

        case .mine:
            guard isIntersecting(player) else { return [] }
            return explode(player)

        case .bubble:
            guard isIntersecting(player), !player.floating else { return [] }
            return beginBubbleLift(player, device: device)

        case .rocketLauncher:
            guard isWithinProximity(of: player) else { return [] }
            return fireRocket(at: player, device: device)

        case .blackHole:
            guard isIntersecting(player) else { return [] }
            return teleport(player)

        case .angelLaser, .unknown:
            guard isIntersecting(player) else { return [] }
            return [.playerHit(sourceID: id, fatal: player.takeHit())]
        }
    }

    /// `action_bat_hit:` — jumping *into* a bat costs health, landing *on* one
    /// bounces the player. Either way the bat dies.
    private func hitByBat(_ player: Player) -> [GameEvent] {
        var events: [GameEvent] = []
        if player.velocity.y > 0 {
            let fatal = player.takeHit()
            events.append(.playerHit(sourceID: id, fatal: fatal))
        } else {
            player.jump(player.jumpSpeed)
            events.append(.playerJumped(platformID: id, boost: 1.0))
        }
        dead = true
        events.append(.enemyKilled(enemyID: id))
        return events
    }

    /// `action_mine_explode:` — one point of damage, mine gone.
    ///
    /// - Note: `Enemy.m` case 2 fell through into case 22, calling this twice
    ///   for stationary mines. This port applies a single hit.
    private func explode(_ player: Player) -> [GameEvent] {
        dead = true
        visible = false
        let fatal = player.takeHit()
        return [.playerHit(sourceID: id, fatal: fatal), .enemyKilled(enemyID: id)]
    }

    /// `action_bubble_float:` — the bubble snaps the player to itself, takes
    /// away control and carries them up over three seconds.
    private func beginBubbleLift(_ player: Player, device: DeviceProfile) -> [GameEvent] {
        running = true
        floating = true
        bubbleElapsed = 0
        bubbleDuration = 3
        bubbleLift = device.bubbleLift

        player.floating = true
        player.controllable = false
        player.velocity = .zero
        player.position = position
        return [.bubbleGrabbed(enemyID: id)]
    }

    /// Advances an in-flight bubble lift, moving the bubble and the player up
    /// together and handing control back at the end.
    public func advanceBubbleLift(deltaTime: Double, player: Player) {
        guard floating, bubbleDuration > 0 else { return }
        let step = min(deltaTime, bubbleDuration - bubbleElapsed)
        guard step > 0 else { return }
        let distance = bubbleLift * (step / bubbleDuration)
        position.y += distance
        player.position.y += distance
        bubbleElapsed += step

        if bubbleElapsed >= bubbleDuration {
            dead = true
            running = false
            floating = false
            player.controllable = true
            player.floating = false
        }
    }

    /// `action_bubble_pop:` — a tap cancels the lift immediately and hands
    /// control straight back to the player.
    @discardableResult
    public func popBubble(_ player: Player) -> [GameEvent] {
        guard kind == .bubble, floating else { return [] }
        dead = true
        running = false
        floating = false
        player.controllable = true
        player.floating = false
        return [.bubblePopped(enemyID: id)]
    }

    /// `action_shoot_rocket:` — spawns a rocket that crosses the screen towards
    /// the player's lane.
    ///
    /// The original's aiming maths is preserved, quirks included: the ratio is
    /// computed against the launch X (27), the flight length uses the far edge
    /// of the screen but the destination X is 0.
    private func fireRocket(at player: Player, device: DeviceProfile) -> [GameEvent] {
        running = true
        projectileCounter += 1
        let projectileID = "\(id)-rocket-\(projectileCounter)"

        let launchX = 27.0
        let verticalOffset = device == .tall ? 355.0 : 300.0
        let launchY = boundingBox.origin.y + verticalOffset
        let launch = Vec2(x: launchX, y: launchY)

        let offX = launchX
        let offY = player.boundingBox.origin.y - launchY
        let realX = device.viewportSize.width + (Projectile.rocketSize.width / 2)
        let ratio = offY / offX
        let realY = realX * ratio + launchY

        let offRealX = realX - launchX
        let offRealY = realY - launchY
        let length = (offRealX * offRealX + offRealY * offRealY).squareRoot()
        let duration = length / device.rocketSpeed

        let projectile = Projectile(
            id: projectileID,
            ownerID: id,
            origin: launch,
            destination: Vec2(x: 0, y: realY),
            duration: duration
        )
        projectiles.append(projectile)
        return [.rocketFired(enemyID: id, projectileID: projectileID)]
    }

    /// `action_teleport_player:` — black holes drop the player at a destination
    /// node and zero their velocity.
    private func teleport(_ player: Player) -> [GameEvent] {
        guard let destination = teleportDestination else { return [] }
        player.velocity = .zero
        player.position = destination
        return [.playerTeleported(enemyID: id, destination: destination)]
    }

    // MARK: - Projectiles

    /// Advances this enemy's projectiles and resolves their hits, mirroring the
    /// projectile block in `GameLayer update:`.
    @discardableResult
    public func updateProjectiles(deltaTime: Double, player: Player) -> [GameEvent] {
        var events: [GameEvent] = []
        for projectile in projectiles {
            projectile.advance(deltaTime: deltaTime)

            if projectile.isIntersecting(player) {
                projectile.visible = false
                // GameLayer.m decremented health twice here; that double hit is
                // treated as a bug and applied once.
                let fatal = player.takeHit()
                events.append(.playerHit(sourceID: projectile.id, fatal: fatal))
                continue
            }

            if projectile.isIntersecting(self) {
                projectile.visible = false
                visible = false
                dead = true
                events.append(.enemyKilled(enemyID: id))
            }
        }
        projectiles.removeAll { !$0.visible }
        if projectiles.isEmpty && kind == .rocketLauncher {
            running = false
        }
        return events
    }
}

import Foundation

/// Engine-agnostic per-frame simulation, ported from `GameLayer update:`.
///
/// The rendering layer owns sprites and the camera; this type owns the state
/// those sprites mirror. Call `update(deltaTime:)` once per frame and apply the
/// returned events (audio, particles, HUD).
public final class GameWorld {
    public let game: Game
    public let level: Level
    public private(set) var platforms: [Platform]
    public private(set) var collectables: [Collectable]
    public private(set) var enemies: [Enemy]
    public private(set) var triggers: [Trigger]
    public private(set) var tips: [Tip]

    public var player: Player { game.player }
    public let device: DeviceProfile

    /// How much of the level is on screen, in authored points.
    ///
    /// The original only ever had two viewports (320x480 and 320x568) so it
    /// could read them straight off `DeviceProfile`. Modern hardware is far
    /// taller and, on iPad, wider, so the rendering layer measures its own
    /// viewport and hands it in. It is clamped so it can never be *smaller*
    /// than the authored viewport: levels assume you can always see the full
    /// 320x480 design box.
    public var viewport: SizeF {
        get { storedViewport }
        set { storedViewport = GameWorld.clampViewport(newValue, to: device) }
    }

    private var storedViewport: SizeF

    private static func clampViewport(_ size: SizeF, to device: DeviceProfile) -> SizeF {
        SizeF(
            width: max(size.width, device.viewportSize.width),
            height: max(size.height, device.viewportSize.height)
        )
    }

    /// Seconds elapsed since the run started; drives moving-platform tweens.
    public private(set) var elapsedTime: Double = 0

    /// Left-over real time not yet consumed by a fixed simulation step.
    private var stepAccumulator: Double = 0

    /// Cached spawn positions so moving nodes ping-pong around their origin.
    private var platformOrigins: [String: Vec2] = [:]
    private var enemyOrigins: [String: Vec2] = [:]

    public init(game: Game, level: Level, device: DeviceProfile = .standard, viewport: SizeF? = nil) {
        self.game = game
        self.level = level
        self.device = device
        self.storedViewport = GameWorld.clampViewport(viewport ?? device.viewportSize, to: device)

        let entities = level.makeEntities()
        platforms = entities.platforms
        collectables = entities.collectables
        enemies = entities.enemies
        triggers = entities.triggers
        tips = entities.tips

        for platform in platforms { platformOrigins[platform.id] = platform.position }
        for enemy in enemies { enemyOrigins[enemy.id] = enemy.position }

        game.player.position = level.playerSpawn
        game.timeLimit = level.metadata.timeLimitSeconds
    }

    /// The topmost point of the level; the camera stops following here.
    public var topBoundaryY: Double { level.metadata.topBoundaryY }

    // MARK: - Fixed timestep

    /// The simulation step every ported physics number assumes.
    ///
    /// `Player move` integrates *per frame*, not per second: `velocity.y -=
    /// gravity` then `position.y += velocity.y`, and `applyHorizontalControl`
    /// clamps to `drag` points per frame. cocos2d ran that at 60Hz, so the whole
    /// game is calibrated to a 1/60s step. Anything else changes the speed of
    /// the game, which is why `advance(realDeltaTime:)` below re-quantises real
    /// time into fixed steps instead of passing the raw frame delta through.
    public static let fixedTimeStep = 1.0 / 60.0

    /// The most fixed steps a single frame may run.
    ///
    /// Without this a long stall (the app returning from the background, a
    /// debugger break) would try to catch up hundreds of steps at once, either
    /// hanging the frame or — worse — teleporting the player far enough in one
    /// go to tunnel straight through a platform. Four steps is one 15fps frame
    /// of catch-up, which is generous for a real hitch and harmless otherwise.
    public static let maxStepsPerFrame = 4

    /// Advances the simulation by however many whole fixed steps `realDeltaTime`
    /// has bought, and reports every event they produced.
    ///
    /// This is the entry point rendering should call. It makes the game run at
    /// the same *speed* on a 60Hz phone, a 120Hz ProMotion phone and a device
    /// dropping frames, and it can never advance the player by more than
    /// `maxStepsPerFrame` sub-steps in one frame.
    @discardableResult
    public func advance(realDeltaTime: Double) -> [GameEvent] {
        guard realDeltaTime.isFinite, realDeltaTime > 0 else { return [] }

        let step = GameWorld.fixedTimeStep
        stepAccumulator += realDeltaTime

        // Drop anything beyond the catch-up budget rather than trying to
        // simulate it: time is lost, but the player is never flung forwards.
        let budget = step * Double(GameWorld.maxStepsPerFrame)
        if stepAccumulator > budget { stepAccumulator = budget }

        var events: [GameEvent] = []
        while stepAccumulator >= step {
            stepAccumulator -= step
            events += update(deltaTime: step)
        }
        return events
    }

    /// Discards any banked partial step. Call this when resuming from a pause so
    /// the first frame back does not inherit stale time.
    public func resetStepAccumulator() {
        stepAccumulator = 0
    }

    // MARK: - Frame update

    /// Advances the simulation by one fixed step.
    ///
    /// Prefer `advance(realDeltaTime:)` from rendering code; this is the raw
    /// step, exposed so tests can drive the simulation deterministically.
    ///
    /// Ordering matches `GameLayer update:`: horizontal control, player
    /// integration, moving nodes, platform landings, collectables, enemies,
    /// projectiles, culling, then the game-over test.
    @discardableResult
    public func update(deltaTime: Double) -> [GameEvent] {
        guard game.isStarted, !game.isGameover else { return [] }

        elapsedTime += deltaTime
        var events: [GameEvent] = []

        if player.isControllable {
            player.applyHorizontalControl(towardX: game.touch.x)
        }
        player.move()

        advanceMovingNodes()

        for platform in platforms {
            events += platform.resolveCollision(with: player, platforms: platforms)
        }

        events += updateCollectables()
        events += updateEnemies(deltaTime: deltaTime)

        cullOffscreenNodes()

        if let gameOver = game.checkGameOver() {
            events.append(gameOver)
        }
        return events
    }

    /// Ping-pong tweens for `moving`/`movingBreakable` platforms and moving
    /// enemies. `animating == false` freezes a node (a breakable that has been
    /// hit stops moving, exactly like the original's `stopAllActions`).
    private func advanceMovingNodes() {
        for platform in platforms {
            guard let motion = platform.motion,
                  platform.animating,
                  let origin = platformOrigins[platform.id] else { continue }
            platform.position = origin + motion.displacement(atTime: elapsedTime)
        }
        for enemy in enemies {
            guard let motion = enemy.motion,
                  !enemy.floating,
                  let origin = enemyOrigins[enemy.id] else { continue }
            enemy.position = origin + motion.displacement(atTime: elapsedTime)
        }
        for enemy in enemies {
            enemy.move(viewport: device.viewportSize)
        }
    }

    private func updateCollectables() -> [GameEvent] {
        var events: [GameEvent] = []
        for collectable in collectables where !collectable.dead {
            if let radius = player.equippedPowerup.magnetRadius,
               collectable.kind == .small,
               collectable.isWithin(radius: radius, of: player) {
                collectable.moveTowards(player)
            }
            if collectable.isIntersecting(player) {
                events.append(collectable.collect(by: player))
            }
        }
        collectables.removeAll { $0.dead && !$0.visible }
        return events
    }

    private func updateEnemies(deltaTime: Double) -> [GameEvent] {
        var events: [GameEvent] = []
        for enemy in enemies {
            if enemy.floating {
                enemy.advanceBubbleLift(deltaTime: deltaTime, player: player)
            } else if enemy.kind == .rocketLauncher && player.equippedPowerup == .dud {
                // The "dud" powerup stops rocket launchers firing (GameLayer.m).
            } else {
                events += enemy.resolveCollision(with: player, device: device)
            }
            events += enemy.updateProjectiles(deltaTime: deltaTime, player: player)
        }
        enemies.removeAll { $0.dead && !$0.visible && $0.projectiles.isEmpty }
        return events
    }

    /// `GameLayer` visibility/despawn book-keeping, expressed in layer space
    /// (the layer scrolls down as the player climbs, so Y here is relative to
    /// the camera, not the level).
    private func cullOffscreenNodes() {
        let cameraOffset = cameraY

        func layerY(_ worldY: Double) -> Double { worldY - cameraOffset }

        for platform in platforms {
            let y = layerY(platform.position.y)
            // The "bound platform" powerup keeps platforms alive off-screen.
            if y < GameConstants.despawnY, player.equippedPowerup != .boundPlatform {
                platform.visible = false
            } else if y > GameConstants.visibilityFloorY, !platform.dead {
                platform.visible = true
            }
        }
        for collectable in collectables {
            let y = layerY(collectable.position.y)
            let floor = collectable.kind == .small
                ? GameConstants.despawnY
                : GameConstants.bigCollectableDespawnY
            if y < floor {
                collectable.visible = false
                collectable.dead = true
            }
        }
        for enemy in enemies where !enemy.floating {
            let y = layerY(enemy.position.y)
            if y < GameConstants.despawnY {
                enemy.visible = false
            } else if y > GameConstants.enemyVisibilityFloorY, !enemy.dead {
                enemy.visible = true
            }
        }
    }

    /// How far the camera has scrolled, i.e. the world Y at the bottom edge of
    /// the screen.
    ///
    /// `GameScene` ran a `CCFollow` on the gameplay layers with a world boundary
    /// of `(0, 0, 320, topBoundaryY)`, so the camera centred on the player but
    /// stopped at the bottom and top of the level.
    ///
    /// Modern screens are much taller than the 480pt the levels were authored
    /// for. Rather than centring the player in that taller viewport — which
    /// would show a lot of already-climbed level below him and shrink the
    /// look-ahead the climb depends on — the surplus height all goes *above*
    /// the player. He keeps exactly `cameraAnchorHeight` points of world
    /// beneath him, the same as the original, so falls and threats from below
    /// read identically; everything extra becomes look-ahead.
    ///
    /// Keeping the bottom edge fixed also keeps `GameConstants.despawnY` and
    /// friends meaningful: they are offsets from the bottom of the screen.
    public var cameraY: Double {
        let anchored = player.position.y - cameraAnchorHeight
        let ceiling = max(0, topBoundaryY - viewport.height)
        return min(max(0, anchored), ceiling)
    }

    /// How much world is kept below the player. Capped at the authored
    /// half-viewport so a *shorter*-than-authored screen still centres him.
    public var cameraAnchorHeight: Double {
        min(device.viewportSize.height / 2, viewport.height / 2)
    }

    // MARK: - Input

    /// The horizontal band the level was authored in. The player is confined to
    /// it, so on a viewport wider than 320pt (iPad) the surplus either side is
    /// scenery, not playable space.
    public var playFieldWidth: Double { device.viewportSize.width }

    /// The player drifts towards the last touch point each frame. The X is
    /// clamped into the play field so a drag that runs off the side of a wide
    /// screen parks him at the edge rather than pulling him out of bounds.
    public func setTouch(_ point: Vec2) {
        game.touch = Vec2(x: min(max(0, point.x), playFieldWidth), y: point.y)
    }

    /// Tapping a floating bubble pops it.
    @discardableResult
    public func handleTap(at point: Vec2) -> [GameEvent] {
        for enemy in enemies where enemy.containsTouch(point) {
            return enemy.popBubble(player)
        }
        return []
    }
}

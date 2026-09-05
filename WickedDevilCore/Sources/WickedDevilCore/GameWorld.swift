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
    /// Seconds elapsed since the run started; drives moving-platform tweens.
    public private(set) var elapsedTime: Double = 0

    /// Cached spawn positions so moving nodes ping-pong around their origin.
    private var platformOrigins: [String: Vec2] = [:]
    private var enemyOrigins: [String: Vec2] = [:]

    public init(game: Game, level: Level, device: DeviceProfile = .standard) {
        self.game = game
        self.level = level
        self.device = device

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

    // MARK: - Frame update

    /// Advances the simulation by one frame.
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

    /// How far the camera has scrolled. The original moved the whole layer down
    /// once the player climbed past the middle of the screen.
    public var cameraY: Double {
        max(0, player.position.y - device.viewportSize.height / 2)
    }

    // MARK: - Input

    /// The player drifts towards the last touch point each frame.
    public func setTouch(_ point: Vec2) {
        game.touch = point
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

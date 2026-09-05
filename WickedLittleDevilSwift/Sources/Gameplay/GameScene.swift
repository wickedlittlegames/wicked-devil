import SpriteKit
import WickedDevilCore

/// The playable gameplay scene.
///
/// This replaces the original's five-layer cocos2d stack (`BGLayer`,
/// `GameLayer`, `FXLayer`, `PlayerLayer`, `UILayer`) with one SpriteKit scene
/// composed of a scrolling world node plus a camera-attached background and
/// HUD. All simulation lives in `WickedDevilCore.GameWorld`; this class only
/// creates nodes, mirrors state onto them each frame, and reacts to the
/// `GameEvent`s the world reports.
final class GameScene: SKScene {

    // MARK: - Layout

    /// The point width every level was authored against.
    static let designWidth = GameplayLayout.designWidth
    /// The point height the original device had, used to place the camera.
    static let designHeight = GameplayLayout.designHeight

    // MARK: - Simulation

    private let game: Game
    private let level: Level
    private let world: GameWorld

    /// Authored appearance for each object, keyed by id, so nodes can be built
    /// lazily as the world spawns things.
    private var platformAppearances: [String: SpriteAppearance] = [:]
    private var collectableAppearances: [String: SpriteAppearance] = [:]
    private var enemyAppearances: [String: SpriteAppearance] = [:]

    // MARK: - Nodes

    private let worldNode = SKNode()
    private let effectsNode = SKNode()
    private let cameraNode = SKCameraNode()
    private var backgroundNode: SKSpriteNode?
    private var hud: HUDNode?
    private var playerNode: PlayerNode?
    private var startPrompt: SKNode?
    private var pausePrompt: SKNode?
    private var messageLabel: SKLabelNode?

    private var platformNodes: [String: SKNode] = [:]
    private var collectableNodes: [String: SKNode] = [:]
    private var enemyNodes: [String: SKNode] = [:]
    private var projectileNodes: [String: SKNode] = [:]

    // MARK: - Frame state

    private var lastUpdateTime: TimeInterval = 0
    private var lastSimulatedTime: TimeInterval = 0
    private var clockAccumulator: TimeInterval = 0
    private var isFinishing = false
    private var hasEnded = false
    private var isInterrupted = false

    /// The insets last used to lay the HUD out, so layout only redoes work when
    /// they actually change.
    private var appliedSafeAreaInsets = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1)
    private var appliedViewSize: CGSize = .zero

    // MARK: - Input

    /// The one touch steering the devil. Extra fingers are ignored outright
    /// rather than fighting over the player's X.
    private var steeringTouch: ObjectIdentifier?
    private var touchLocation: CGPoint?

    /// Called once the run is over so a host can show results or restart.
    var onGameOver: ((GameResult) -> Void)?

    // MARK: - Init

    init(game: Game, level: Level, size: CGSize) {
        self.game = game
        self.level = level
        self.world = GameWorld(
            game: game,
            level: level,
            device: .standard,
            viewport: SizeF(width: Double(size.width), height: Double(size.height))
        )
        super.init(size: size)
        // The scene is sized to the view's exact aspect, so `aspectFill` neither
        // crops nor letterboxes; it just scales the authored points to pixels.
        scaleMode = .aspectFill
        // The world is authored bottom-left origin, matching SpriteKit.
        anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = .black
        indexAppearances()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    private func indexAppearances() {
        for data in level.platforms { platformAppearances[data.id] = SpriteAppearance(data) }
        for data in level.collectables { collectableAppearances[data.id] = SpriteAppearance(data) }
        for data in level.enemies { enemyAppearances[data.id] = SpriteAppearance(data) }
    }

    // MARK: - Scene setup

    override func didMove(to view: SKView) {
        guard worldNode.parent == nil else { return }

        GameFont.register()
        AudioEngine.shared.preloadEffects(SoundEffect.all)

        buildBackground()
        addChild(worldNode)
        worldNode.addChild(effectsNode)
        effectsNode.zPosition = ZOrder.effects

        camera = cameraNode
        addChild(cameraNode)

        buildHUD()
        buildStartPrompt()
        observeInterruptions()

        spawnPlayer()
        applyLayout(for: view)
        syncNodes()
        positionCamera()

        if let track = LevelCatalog.musicTrack(world: game.world) {
            AudioEngine.shared.playMusic(track)
        }
    }

    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Responsive layout

    /// Re-derives the scene size and safe-area insets from the live view.
    ///
    /// `SKView` does not report final safe-area insets until it has been laid
    /// out, and on iPad the view can be resized after the scene is built, so
    /// this runs on every frame and only does work when something moved.
    private func applyLayout(for view: SKView) {
        let viewSize = view.bounds.size
        guard viewSize.width > 0, viewSize.height > 0 else { return }

        let insets = view.safeAreaInsets
        guard viewSize != appliedViewSize || insets != appliedSafeAreaInsets else { return }
        appliedViewSize = viewSize
        appliedSafeAreaInsets = insets

        let target = GameplayLayout.sceneSize(forViewSize: viewSize)
        if abs(target.width - size.width) > 0.01 || abs(target.height - size.height) > 0.01 {
            size = target
            world.viewport = SizeF(width: Double(size.width), height: Double(size.height))
        }

        let ratio = GameplayLayout.scenePointsPerViewPoint(sceneSize: size, viewSize: viewSize)
        let safeArea = SafeAreaInsets(
            top: insets.top * ratio,
            bottom: insets.bottom * ratio
        )

        resizeBackground()
        hud?.layout(sceneSize: size, safeArea: safeArea)
        layoutStartPrompt(safeArea: safeArea)
        layoutPausePrompt()
    }

    private func buildBackground() {
        // `BGLayer createWorldSpecificBackgrounds:` tiled a single image behind
        // everything. Attaching it to the camera keeps it fixed, which is what
        // the original's parallax ratio of 0 amounted to for the base layer.
        guard let image = SpriteLibrary.image(named: LevelCatalog.backgroundImage(world: game.world))
        else { return }
        let node = SKSpriteNode(texture: image.texture)
        node.zPosition = ZOrder.background
        cameraNode.addChild(node)
        backgroundNode = node
        resizeBackground()
    }

    /// Covers the whole scene regardless of aspect, so the surplus width an
    /// iPad has either side of the 320pt play column is never bare black.
    private func resizeBackground() {
        guard let backgroundNode, let texture = backgroundNode.texture else { return }
        let source = texture.size()
        guard source.width > 0, source.height > 0 else { return }
        let scale = max(size.width / source.width, size.height / source.height)
        backgroundNode.size = CGSize(width: source.width * scale, height: source.height * scale)
    }

    private func buildHUD() {
        let node = HUDNode(game: game)
        cameraNode.addChild(node)
        node.update(game: game)
        hud = node
    }

    private func buildStartPrompt() {
        // `GameScene.m` gated the run behind a Begin button; any tap now starts.
        let container = SKNode()
        container.zPosition = ZOrder.overlay

        if let image = SpriteLibrary.image(named: "Begin-Button") {
            let button = SKSpriteNode(texture: image.texture, size: image.size)
            container.addChild(button)
            button.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.6, duration: 0.6),
                SKAction.fadeAlpha(to: 1.0, duration: 0.6),
            ])))
        }

        cameraNode.addChild(container)
        startPrompt = container
    }

    /// Keeps the Begin button clear of the home indicator.
    private func layoutStartPrompt(safeArea: SafeAreaInsets) {
        startPrompt?.position = CGPoint(
            x: 0,
            y: -size.height / 2 + safeArea.bottom + GameScene.bottomPromptMargin
        )
    }

    /// Room for the Begin/Resume prompts above the home indicator.
    private static let bottomPromptMargin: CGFloat = 60

    private func spawnPlayer() {
        let node = PlayerNode(
            atlasName: game.player.animationAtlasName,
            contentSize: CGSize(
                width: game.player.contentSize.width,
                height: game.player.contentSize.height
            )
        )
        node.setScale(game.player.scale)
        worldNode.addChild(node)
        playerNode = node
    }

    // MARK: - Frame loop

    override func update(_ currentTime: TimeInterval) {
        if let view { applyLayout(for: view) }

        defer { lastUpdateTime = currentTime }
        guard lastUpdateTime > 0 else { return }
        guard !isInterrupted else { return }

        let realDeltaTime = currentTime - lastUpdateTime
        guard realDeltaTime > 0 else { return }

        if let touchLocation {
            world.setTouch(Vec2(x: Double(touchLocation.x), y: Double(touchLocation.y)))
        }

        // `advance` re-quantises real time into the 1/60s steps the ported
        // physics assumes, so the game runs at one speed on 60Hz and 120Hz
        // panels alike and a hitch cannot leap the simulation forwards.
        let events = world.advance(realDeltaTime: realDeltaTime)
        handle(events)

        // Drive the level clock off *simulated* time, so a stalled frame that
        // only bought four steps does not also burn a full second of the limit.
        advanceClock(by: world.elapsedTime - lastSimulatedTime)
        lastSimulatedTime = world.elapsedTime
        syncNodes()
        positionCamera()
        hud?.update(game: game)
    }

    /// `GameScene countdown:` ran on a one-second `CCRepeatForever`.
    private func advanceClock(by deltaTime: TimeInterval) {
        guard game.isStarted, !game.isGameover else { return }
        clockAccumulator += deltaTime
        while clockAccumulator >= 1 {
            clockAccumulator -= 1
            game.tickClock()
        }
    }

    private func positionCamera() {
        cameraNode.position = CGPoint(
            x: Self.designWidth / 2,
            y: CGFloat(world.cameraY) + size.height / 2
        )
    }

    // MARK: - Interruption

    /// `AppDelegate applicationWillResignActive:` paused the director on an
    /// incoming call. This does the same, but does *not* auto-resume: coming
    /// back mid-fall with no finger on the glass is an unearned death, so the
    /// player taps to restart the clock.
    private func observeInterruptions() {
        let centre = NotificationCenter.default
        centre.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc private func handleWillResignActive() {
        guard game.isStarted, !game.isGameover, !hasEnded, !isInterrupted else { return }
        isInterrupted = true
        releaseSteering()
        isPaused = true
        AudioEngine.shared.stopMusic()
        showPausePrompt()
    }

    private func resumeAfterInterruption() {
        guard isInterrupted else { return }
        isInterrupted = false
        isPaused = false
        // Neither the banked sub-step nor the frame delta spanning the pause is
        // real play time.
        world.resetStepAccumulator()
        lastUpdateTime = 0
        clockAccumulator = 0
        pausePrompt?.removeFromParent()
        pausePrompt = nil
        if let track = LevelCatalog.musicTrack(world: game.world) {
            AudioEngine.shared.playMusic(track)
        }
    }

    private func showPausePrompt() {
        guard pausePrompt == nil else { return }
        let label = SKLabelNode(text: "TAP TO RESUME")
        label.fontName = GameFont.preferredName
        label.fontSize = 28
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = ZOrder.overlay
        cameraNode.addChild(label)
        pausePrompt = label
        layoutPausePrompt()
    }

    private func layoutPausePrompt() {
        pausePrompt?.position = .zero
    }

    // MARK: - Node synchronisation

    private func syncNodes() {
        sync(
            entities: world.platforms,
            nodes: &platformNodes,
            id: \.id,
            make: { [weak self] platform in
                EntityNodeFactory.platformNode(
                    appearance: self?.platformAppearances[platform.id],
                    fallbackSize: platform.contentSize
                )
            },
            apply: { platform, node in
                node.position = CGPoint(x: platform.position.x, y: platform.position.y)
                node.isHidden = !platform.visible
            }
        )

        sync(
            entities: world.collectables,
            nodes: &collectableNodes,
            id: \.id,
            make: { [weak self] collectable in
                EntityNodeFactory.collectableNode(
                    appearance: self?.collectableAppearances[collectable.id],
                    kind: collectable.kind,
                    fallbackSize: collectable.contentSize
                )
            },
            apply: { collectable, node in
                node.position = CGPoint(x: collectable.position.x, y: collectable.position.y)
                node.isHidden = !collectable.visible
            }
        )

        sync(
            entities: world.enemies,
            nodes: &enemyNodes,
            id: \.id,
            make: { [weak self] enemy in
                EntityNodeFactory.enemyNode(
                    appearance: self?.enemyAppearances[enemy.id],
                    kind: enemy.kind,
                    fallbackSize: enemy.contentSize
                )
            },
            apply: { enemy, node in
                node.position = CGPoint(x: enemy.position.x, y: enemy.position.y)
                node.isHidden = !enemy.visible
            }
        )

        let projectiles = world.enemies.flatMap(\.projectiles)
        sync(
            entities: projectiles,
            nodes: &projectileNodes,
            id: \.id,
            make: { projectile in EntityNodeFactory.projectileNode(size: projectile.contentSize) },
            apply: { projectile, node in
                node.position = CGPoint(x: projectile.position.x, y: projectile.position.y)
                node.isHidden = !projectile.visible
            }
        )

        if let playerNode {
            let player = game.player
            playerNode.position = CGPoint(x: player.position.x, y: player.position.y)
            playerNode.syncAnimation(with: player)
        }
    }

    /// Adds nodes for new entities, updates existing ones, and removes any node
    /// whose entity the world has culled.
    private func sync<Entity>(
        entities: [Entity],
        nodes: inout [String: SKNode],
        id: KeyPath<Entity, String>,
        make: (Entity) -> SKNode,
        apply: (Entity, SKNode) -> Void
    ) {
        var live = Set<String>()
        live.reserveCapacity(entities.count)

        for entity in entities {
            let key = entity[keyPath: id]
            live.insert(key)
            let node: SKNode
            if let existing = nodes[key] {
                node = existing
            } else {
                node = make(entity)
                nodes[key] = node
                worldNode.addChild(node)
            }
            apply(entity, node)
        }

        for (key, node) in nodes where !live.contains(key) {
            node.removeFromParent()
            nodes[key] = nil
        }
    }

    // MARK: - Events

    private func handle(_ events: [GameEvent]) {
        for event in events { handle(event) }
    }

    private func handle(_ event: GameEvent) {
        switch event {
        case let .playerJumped(platformID, boost):
            playerNode?.playJump(for: game.player)
            playJumpSound(platformID: platformID, boost: boost)

        case .platformBroke:
            AudioEngine.shared.playEffect(SoundEffect.jumpBreakable, gain: 0.5)

        case .platformsToggled:
            AudioEngine.shared.playEffect(SoundEffect.click, gain: 0.5)

        case let .levelFinished(_, didWin):
            beginFinish(didWin: didWin)

        case let .collected(id, kind):
            handleCollected(id: id, kind: kind)

        case let .playerHit(sourceID, fatal):
            handlePlayerHit(sourceID: sourceID, fatal: fatal)

        case .enemyKilled:
            AudioEngine.shared.playEffect(SoundEffect.boom)

        case .bubbleGrabbed, .bubblePopped:
            AudioEngine.shared.playEffect(SoundEffect.bubble)

        case .rocketFired:
            AudioEngine.shared.playEffect(SoundEffect.boom, gain: 0.4)

        case .playerTeleported:
            AudioEngine.shared.playEffect(SoundEffect.bubble, gain: 0.6)

        case let .gameOver(didWin):
            endRun(didWin: didWin)
        }
    }

    /// `Platform playAudio:` picked the sample from the platform's tag.
    private func playJumpSound(platformID: String, boost: Double) {
        let kind = world.platforms.first { $0.id == platformID }?.kind
        switch kind {
        case .boost:
            AudioEngine.shared.playEffect(SoundEffect.jumpBoost, gain: 0.5)
        case .breakable, .movingBreakable:
            AudioEngine.shared.playEffect(SoundEffect.jumpBreakable, gain: 0.5)
        case .goal:
            AudioEngine.shared.playEffect(SoundEffect.complete)
        default:
            // Anything with an unusual boost still reads as a "special" bounce.
            let effect = boost > 1.0 ? SoundEffect.jumpBoost : SoundEffect.jumpNormal
            AudioEngine.shared.playEffect(effect, gain: 0.5)
        }
    }

    private func handleCollected(id: String, kind: CollectableKind) {
        let position = collectableNodes[id]?.position
        switch kind {
        case .small:
            AudioEngine.shared.playEffect(SoundEffect.collectSmall, gain: 0.2)
        case .big:
            AudioEngine.shared.playEffect(SoundEffect.bigCollect(index: game.player.bigCollected))
            emit(ParticleEffect.bigCollectable, at: position)
        case .halo:
            AudioEngine.shared.playEffect(SoundEffect.halo)
            emit(ParticleEffect.halo, at: position)
        }
    }

    private func handlePlayerHit(sourceID: String, fatal: Bool) {
        let source = world.enemies.first { $0.id == sourceID }
        switch source?.kind {
        case .bat:
            AudioEngine.shared.playEffect(SoundEffect.batHit)
        case .mine, .rocketLauncher, .none:
            AudioEngine.shared.playEffect(SoundEffect.boom)
            emit(ParticleEffect.mineExplosion, at: enemyNodes[sourceID]?.position)
        default:
            AudioEngine.shared.playEffect(SoundEffect.playerHit)
        }
        if fatal {
            playerNode?.syncAnimation(with: game.player)
        }
    }

    private func emit(_ effect: String, at position: CGPoint?) {
        guard let position, let emitter = ParticleFactory.emitter(named: effect) else { return }
        emitter.position = position
        emitter.zPosition = ZOrder.effects
        effectsNode.addChild(emitter)
        // Long enough for the burst to finish and fade.
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.removeFromParent(),
        ]))
    }

    /// `Platform action:` case 100 delayed the win by a second so the player
    /// could see the landing.
    private func beginFinish(didWin: Bool) {
        guard !isFinishing else { return }
        isFinishing = true
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                guard let self else { return }
                if let event = self.game.finish(didWin: didWin) {
                    self.handle(event)
                }
            },
        ]))
    }

    private func endRun(didWin: Bool) {
        guard !hasEnded else { return }
        hasEnded = true

        if !game.player.isAlive {
            AudioEngine.shared.playEffect(SoundEffect.playerHit)
        }
        AudioEngine.shared.stopMusic()
        showMessage(didWin ? "LEVEL COMPLETE" : "GAME OVER")
        onGameOver?(game.result)
    }

    private func showMessage(_ text: String) {
        let label = SKLabelNode(text: text)
        label.fontName = GameFont.preferredName
        label.fontSize = 36
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = .zero
        label.zPosition = ZOrder.overlay
        label.setScale(0.2)
        cameraNode.addChild(label)
        label.run(SKAction.scale(to: 1, duration: 0.3))
        messageLabel = label
    }

    // MARK: - Input

    /// `GameScene ccTouchesMoved:` drove the player's x straight from the touch
    /// position; `control_player` clamped how fast it could follow.
    ///
    /// That absolute mapping is kept rather than switching to a relative drag,
    /// because the scene is scaled so the play field is always exactly 320
    /// authored points wide: a touch a third of the way across the glass still
    /// asks for a third of the way across the field, on any device. What has
    /// changed is the book-keeping around it — one steering finger, a request
    /// clamped to the field, and no snap when the run begins.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isInterrupted {
            resumeAfterInterruption()
            return
        }

        guard let touch = touches.first(where: { $0.phase != .cancelled }) else { return }

        // First finger down wins and keeps steering until it lifts; later
        // fingers can still pop bubbles but never yank the devil sideways.
        let isSteering: Bool
        if steeringTouch == nil {
            steeringTouch = ObjectIdentifier(touch)
            isSteering = true
        } else {
            isSteering = ObjectIdentifier(touch) == steeringTouch
        }

        let location = touch.location(in: worldNode)

        if !game.isStarted {
            startRun()
            return
        }

        if isSteering { touchLocation = location }

        // Tapping a floating bubble pops it.
        handle(world.handleTap(at: Vec2(x: Double(location.x), y: Double(location.y))))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let steeringTouch,
              let touch = touches.first(where: { ObjectIdentifier($0) == steeringTouch })
        else { return }
        // A drag that runs off the edge of the glass keeps steering: the world
        // clamps the request into the play field rather than dropping it.
        touchLocation = touch.location(in: worldNode)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endSteering(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endSteering(touches)
    }

    /// Only the steering finger lifting stops the devil; other fingers leaving
    /// are irrelevant. The last requested X is held, matching the original,
    /// where `game.touch` simply kept its value once you let go.
    private func endSteering(_ touches: Set<UITouch>) {
        guard let steeringTouch,
              touches.contains(where: { ObjectIdentifier($0) == steeringTouch })
        else { return }
        releaseSteering()
    }

    private func releaseSteering() {
        steeringTouch = nil
        touchLocation = nil
    }

    /// `GameScene tap_launch` set `game.touch = game.player.position`, so the
    /// devil launched straight up instead of snapping across to wherever the
    /// Begin button happened to be tapped.
    private func startRun() {
        AudioEngine.shared.playEffect(SoundEffect.click)
        startPrompt?.removeFromParent()
        startPrompt = nil
        releaseSteering()
        game.start()
        world.setTouch(game.player.position)
        playerNode?.playJump(for: game.player)
    }
}

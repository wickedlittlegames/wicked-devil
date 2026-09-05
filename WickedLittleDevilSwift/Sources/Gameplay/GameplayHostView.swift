import SpriteKit
import SwiftUI
import WickedDevilCore

/// SwiftUI host for the SpriteKit gameplay scene.
///
/// This is the gameplay side of the `GameplayHandoff` contract: it builds a run
/// from a `GameLaunchRequest`, plays it, and calls `finish` exactly once with
/// the `GameResult`. Persistence stays with the menu layer.
struct GameplayHostView: View {
    let request: GameLaunchRequest
    let user: User?
    let onFinish: (GameResult?) -> Void

    @State private var scene: GameScene?
    @State private var loadError: String?
    /// The request actually being played. Diverges from `request` after the
    /// first death, because a restart re-launches the level in place.
    @State private var currentRequest: GameLaunchRequest?
    /// Bumped for every run so SwiftUI tears the `SKView` down and builds a
    /// fresh one instead of reusing the finished scene.
    @State private var runToken = 0
    @State private var viewSize: CGSize = .zero

    init(
        request: GameLaunchRequest,
        user: User? = nil,
        onFinish: @escaping (GameResult?) -> Void
    ) {
        self.request = request
        self.user = user
        self.onFinish = onFinish
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                if let scene {
                    // The simulation is fixed at 1/60s steps inside
                    // `GameWorld.advance`, so rendering is free to run at the
                    // display's native rate: 120Hz on ProMotion gives smoother
                    // motion without touching game speed.
                    SpriteView(scene: scene, preferredFramesPerSecond: 120)
                        .id(runToken)
                } else if let loadError {
                    VStack(spacing: 12) {
                        Text("Could not load \(request.levelResourceName)")
                        Text(loadError)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button("Back") { onFinish(nil) }
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(.white)
                }
            }
            .onAppear {
                viewSize = proxy.size
                build(for: proxy.size)
            }
            .onChange(of: proxy.size) { _, newSize in viewSize = newSize }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }

    /// Levels were authored for a 320x480 point screen. The scene is scaled so
    /// that box always fits exactly, and the device's surplus — height on a
    /// phone, width on an iPad — becomes scenery. See `GameplayLayout`.
    ///
    /// The scene re-measures itself against the live `SKView` every frame, so
    /// this only needs to be close enough to avoid a first-frame pop.
    private func build(for viewSize: CGSize) {
        guard scene == nil else { return }
        start(request: currentRequest ?? request, size: viewSize)
    }

    /// Death and the pause menu's restart both replay the level *inside* the
    /// gameplay layer. `GameLayer.m end:` did the same: it reloaded the scene
    /// rather than returning to the menus. Bouncing out through SwiftUI instead
    /// made the results cover flash and could re-present the finished scene, so
    /// the run never handed a loss back to the menu layer at all.
    private func restart() {
        let next = (currentRequest ?? request).restarted()
        scene = nil
        runToken += 1
        start(request: next, size: viewSize)
    }

    private func start(request: GameLaunchRequest, size viewSize: CGSize) {
        currentRequest = request
        loadError = nil
        let size = GameplayLayout.sceneSize(forViewSize: viewSize)

        do {
            let level = try LevelCatalog.load(world: request.world, level: request.level)
            let player = Player(device: .standard)
            // `GameScene.m` forced the detective in world 20, otherwise only
            // honoured the bought character; everyone else gets the plain devil.
            if request.world == 20 {
                player.setupCharacter(.detective)
            } else if user?.boughtCharacter == true,
                      let raw = user?.character,
                      let character = PlayerCharacter(rawValue: raw) {
                player.setupCharacter(character)
            }
            if let powerup = user?.powerup {
                player.setupPowerup(rawValue: powerup)
            }
            let game = Game(
                world: request.world,
                level: request.level,
                player: player,
                user: user,
                pastScore: request.pastScore,
                timeLimit: level.metadata.timeLimitSeconds,
                isRestart: request.isRestart
            )
            let newScene = GameScene(game: game, level: level, size: size)
            // Only a win leaves the gameplay layer; a loss replays the level in
            // place so the player never sees the menus or a results screen.
            newScene.onGameOver = { result in
                if result.didWin {
                    onFinish(result)
                } else {
                    restart()
                }
            }
            // `UILayer tap_mainmenu` replaced the scene with the level select;
            // the handoff's "quit without finishing" case does the same job and
            // keeps persistence with the menu layer.
            newScene.onQuit = { onFinish(nil) }
            // `UILayer tap_reload` reloaded the scene with `isRestart:TRUE`.
            newScene.onRestart = { restart() }
            scene = newScene
        } catch {
            loadError = error.localizedDescription
        }
    }
}

extension GameplayLauncher {
    /// The real SpriteKit launcher; inject this into the menu layer's
    /// environment to replace `GameplayLauncher.placeholder`.
    static func spriteKit(user: User? = nil) -> GameplayLauncher {
        GameplayLauncher { request, finish in
            AnyView(GameplayHostView(request: request, user: user, onFinish: finish))
        }
    }
}

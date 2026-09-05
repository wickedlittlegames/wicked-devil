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
                    SpriteView(scene: scene, preferredFramesPerSecond: 60)
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
            .onAppear { build(for: proxy.size) }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }

    /// Levels were authored for a 320pt-wide screen. Keeping that width fixed
    /// and deriving the height from the device aspect preserves the original
    /// horizontal feel with no cropping; taller phones simply see further up
    /// the level, which suits a vertical climber.
    private func build(for viewSize: CGSize) {
        guard scene == nil else { return }
        let width = GameScene.designWidth
        let aspect = viewSize.height > 0 && viewSize.width > 0
            ? viewSize.height / viewSize.width
            : GameScene.designHeight / GameScene.designWidth
        let size = CGSize(width: width, height: (width * aspect).rounded())

        do {
            let level = try LevelCatalog.load(world: request.world, level: request.level)
            let player = Player(device: .standard)
            if let raw = user?.character, let character = PlayerCharacter(rawValue: raw) {
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
            newScene.onGameOver = { result in onFinish(result) }
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

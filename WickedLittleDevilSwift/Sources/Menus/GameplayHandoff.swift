import SwiftUI
import WickedDevilCore

// MARK: - The menu ➜ gameplay hand-off contract
//
// This file is the **only** coupling point between the SwiftUI menu layer and
// the SpriteKit gameplay layer. The menu layer never references `GameScene`,
// `SKScene` or anything else from the gameplay workstream; it hands over a
// `GameLaunchRequest` and waits for a `GameResult`.
//
// To plug gameplay in, build a `GameplayLauncher` and inject it into the
// environment above `MenuRootView`:
//
// ```swift
// MenuRootView()
//     .environment(\.gameplayLauncher, GameplayLauncher { request, finish in
//         AnyView(GameplayHostView(request: request, onFinish: finish))
//     })
// ```
//
// The gameplay view's obligations are:
//
// 1. Build the run from `request.world` / `request.level`, honouring
//    `request.isRestart` and seeding `Game.pastScore` with `request.pastScore`.
// 2. Call `finish(result)` **exactly once**:
//    * `.some(result)` when the run ended — win *or* loss. Use
//      `Game.result` from `WickedDevilCore` to build it, so `didWin` is set.
//    * `.none` when the player quit from the pause menu without finishing.
// 3. Not touch `User` itself. The menu layer owns persistence: it calls
//    `User.recordCompletedLevel(_:)` for a win, so souls, high scores, halos,
//    progression and achievements are banked in exactly one place.

/// Everything the gameplay layer needs to start a run.
struct GameLaunchRequest: Identifiable, Hashable, Sendable {
    let world: Int
    let level: Int
    /// `GameScene sceneWithWorld:andLevel:isRestart:` — `true` when the player
    /// died and the level is being replayed.
    let isRestart: Bool
    /// The player's previous best score for this level, shown on the HUD.
    let pastScore: Int

    init(world: Int, level: Int, isRestart: Bool = false, pastScore: Int = 0) {
        self.world = world
        self.level = level
        self.isRestart = isRestart
        self.pastScore = pastScore
    }

    var id: String { "\(world)-\(level)-\(isRestart)" }

    /// Bundle-relative name of the level JSON, e.g. `world-3-level-17`.
    var levelResourceName: String { "world-\(world)-level-\(level)" }

    var isBonusLevel: Bool {
        world == GameConstants.bonusWorld && level == GameConstants.bonusLevel
    }

    var isDetectiveLevel: Bool { world == GameConstants.detectiveWorld }

    func restarted() -> GameLaunchRequest {
        GameLaunchRequest(world: world, level: level, isRestart: true, pastScore: pastScore)
    }
}

/// Builds the gameplay view for a launch request.
///
/// A struct wrapping a closure rather than a protocol, so the gameplay
/// workstream can supply anything view-shaped without the menu layer knowing
/// its type.
struct GameplayLauncher {
    /// - Parameters:
    ///   - request: the level to play.
    ///   - finish: must be called exactly once. Pass the run's `GameResult`,
    ///     or `nil` if the player quit without finishing.
    let makeGameplayView: (_ request: GameLaunchRequest, _ finish: @escaping (GameResult?) -> Void) -> AnyView

    init(makeGameplayView: @escaping (GameLaunchRequest, @escaping (GameResult?) -> Void) -> AnyView) {
        self.makeGameplayView = makeGameplayView
    }

    /// Stand-in used until the SpriteKit scene is wired up, and by previews.
    /// It shows the request and lets you simulate a win, a loss or a quit, so
    /// the whole menu flow is exercisable without gameplay.
    static let placeholder = GameplayLauncher { request, finish in
        AnyView(GameplayPlaceholderView(request: request, finish: finish))
    }
}

private struct GameplayLauncherKey: EnvironmentKey {
    static let defaultValue = GameplayLauncher.placeholder
}

extension EnvironmentValues {
    var gameplayLauncher: GameplayLauncher {
        get { self[GameplayLauncherKey.self] }
        set { self[GameplayLauncherKey.self] = newValue }
    }
}

/// Development stand-in for the real gameplay scene.
struct GameplayPlaceholderView: View {
    let request: GameLaunchRequest
    let finish: (GameResult?) -> Void

    @State private var souls = 3
    @State private var smallSouls = 40
    @State private var halos = 1
    @State private var seconds = 18

    var body: some View {
        VStack(spacing: 20) {
            Text("Gameplay hand-off")
                .font(.devilTitle(30))

            MenuPanel {
                VStack(alignment: .leading, spacing: 8) {
                    labelled("Level", request.levelResourceName)
                    labelled("Restart", request.isRestart ? "yes" : "no")
                    labelled("Past score", request.pastScore.formatted(.number))
                    Divider().overlay(MenuColor.panelStroke)
                    stepper("Big souls", value: $souls, range: 0...3)
                    stepper("Small souls", value: $smallSouls, range: 0...200, step: 10)
                    stepper("Halos", value: $halos, range: 0...1)
                    stepper("Seconds taken", value: $seconds, range: 0...120, step: 5)
                }
            }

            VStack(spacing: 10) {
                Button("Finish — win") { finish(result(didWin: true)) }
                    .devilButton()
                Button("Finish — died") { finish(result(didWin: false)) }
                    .devilButton(.secondary)
                Button("Quit to menu") { finish(nil) }
                    .devilButton(.quiet)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(MenuColor.text)
        .background { MenuBackground("bg-world-\(request.world)", dim: 0.6) }
    }

    private func labelled(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.devilBody(16)).foregroundStyle(MenuColor.mutedText)
            Spacer()
            Text(value).font(.devilBody(16))
        }
    }

    private func stepper(_ title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int = 1) -> some View {
        Stepper(value: value, in: range, step: step) {
            HStack {
                Text(title).font(.devilBody(16)).foregroundStyle(MenuColor.mutedText)
                Spacer()
                Text(value.wrappedValue.formatted(.number)).font(.devilBody(16))
            }
        }
        .tint(MenuColor.ember)
    }

    private func result(didWin: Bool) -> GameResult {
        GameResult(
            world: request.world,
            level: request.level,
            bigCollected: souls,
            collected: smallSouls,
            haloCollected: halos,
            timeLimit: GameConstants.baseTimeLimitSeconds,
            timeTaken: seconds,
            pointsPerCollectable: 10,
            didWin: didWin
        )
    }
}

#Preview("Gameplay placeholder") {
    GameplayPlaceholderView(
        request: GameLaunchRequest(world: 2, level: 7, pastScore: 4200),
        finish: { _ in }
    )
}

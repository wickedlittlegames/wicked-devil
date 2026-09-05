import SwiftUI
import WickedDevilCore

/// Destinations reachable from the title screen.
enum MenuRoute: Hashable {
    case worldSelect
    case levelSelect(world: Int)
    case adventureSelect
    case detectiveLevelSelect
    case storeHub
    case powerupShop
    case specialShop
    case characterShop
    case soulShop
    case stats
}

/// The menu layer's root.
///
/// Owns the navigation stack, the `MenuModel`, and the gameplay hand-off:
/// gameplay is presented as a full-screen cover over the menus, so the menu
/// stack survives a run and the player lands back where they started.
///
/// Deliberately a separate root from `ContentView` so the gameplay workstream
/// can keep editing that file without colliding here. Point the app at this
/// view (see `MenuRootView.hosted(...)`) when the menus should be the entry
/// point.
struct MenuRootView: View {
    @State private var model: MenuModel
    @State private var path: [MenuRoute] = []
    /// The run currently being played, if any.
    @State private var activeRun: GameLaunchRequest?
    /// The finished run whose results are being shown.
    @State private var finishedRun: FinishedRun?
    /// A result waiting to be shown after gameplay has fully dismissed.
    @State private var pendingFinishedRun: FinishedRun?
    /// Bumped for every launch. Folded into the cover's identity so two runs of
    /// the same level (which share a `GameLaunchRequest.id`) never reuse a
    /// finished gameplay view.
    @State private var runToken = 0

    @Environment(\.gameplayLauncher) private var launcher

    init(model: MenuModel = MenuModel()) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack(path: $path) {
            TitleView(
                onPlay: { path.append(.worldSelect) },
                onAdventures: { path.append(.adventureSelect) },
                onStore: { path.append(.storeHub) },
                onStats: { path.append(.stats) },
                onBonusLevel: { play(world: GameConstants.bonusWorld, level: GameConstants.bonusLevel) },
                onUnlockEverything: {
                    model.unlockEverything()
                }
            )
            .navigationDestination(for: MenuRoute.self, destination: destination)
        }
        .environment(model)
        .tint(MenuColor.ember)
        .preferredColorScheme(.dark)
        .onAppear(perform: updateMenuMusic)
        .onChange(of: activeRun) { _, _ in updateMenuMusic() }
        .onChange(of: model.isMuted) { _, _ in updateMenuMusic() }
        .fullScreenCover(item: $activeRun) { request in
            launcher.makeGameplayView(request) { result in
                finish(request: request, result: result)
            }
            .ignoresSafeArea()
            .id("\(request.id)-\(runToken)")
        }
        .fullScreenCover(item: $finishedRun) { run in
            GameOverView(
                run: run,
                onRetry: { play(request: run.request.restarted()) },
                onNext: {
                    if let next = model.nextLevel(after: run.request) { play(request: next) }
                },
                onMenu: { finishedRun = nil },
                onStore: {
                    finishedRun = nil
                    if path.last != .storeHub { path.append(.storeHub) }
                }
            )
        }
    }

    @ViewBuilder
    private func destination(_ route: MenuRoute) -> some View {
        switch route {
        case .worldSelect:
            WorldSelectView(
                onSelectWorld: { path.append(.levelSelect(world: $0)) },
                onStore: { path.append(.storeHub) },
                onStats: { path.append(.stats) },
                onBack: pop
            )
        case .levelSelect(let world):
            LevelSelectView(
                world: world,
                onPlay: { play(world: world, level: $0) },
                onStore: { path.append(.storeHub) },
                onBack: pop
            )
        case .adventureSelect:
            AdventureSelectView(
                onEnterDetective: { path.append(.detectiveLevelSelect) },
                onStore: { path.append(.storeHub) },
                onBack: pop
            )
        case .detectiveLevelSelect:
            DetectiveLevelSelectView(
                onPlay: { play(world: GameConstants.detectiveWorld, level: $0) },
                onBack: pop
            )
        case .storeHub:
            StoreHubView(
                onOpen: { path.append($0) },
                onBack: pop
            )
        case .powerupShop:
            UpgradeShopView(kind: .devil, onBack: pop)
        case .specialShop:
            UpgradeShopView(kind: .special, onBack: pop)
        case .characterShop:
            CharacterShopView(onBack: pop)
        case .soulShop:
            SoulShopView(onBack: pop)
        case .stats:
            StatsView(onBack: pop)
        }
    }

    // MARK: - Menu music

    /// `StartScene.m` played `bg-main` behind the menus, and `GameOverScene.m`
    /// brought it back after a run. The whole menu stack shares the one track,
    /// so pushing and popping screens leaves it playing uninterrupted; a run
    /// takes the music over and hands it back on the way out.
    private func updateMenuMusic() {
        guard activeRun == nil else { return }
        if model.isMuted {
            AudioEngine.shared.stopMusic()
        } else {
            AudioEngine.shared.playMusic(MusicTrack.menu)
        }
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    // MARK: - Gameplay hand-off

    private func play(world: Int, level: Int) {
        play(request: model.launchRequest(world: world, level: level))
    }

    private func play(request: GameLaunchRequest) {
        finishedRun = nil
        pendingFinishedRun = nil
        runToken += 1
        // Let any presented cover dismiss before the next one goes up.
        DispatchQueue.main.async { activeRun = request }
    }

    /// Called by the gameplay layer exactly once per run.
    ///
    /// * `nil` — the player quit; just return to the menus.
    /// * a loss — a safety net only: `GameplayHostView` now replays the level
    ///   in place, matching `GameLayer.m end:`, so losses should not arrive.
    /// * a win — bank it and show the results.
    private func finish(request: GameLaunchRequest, result: GameResult?) {
        DispatchQueue.main.async {
            activeRun = nil

            guard let result else { return }

            guard result.didWin else {
                play(request: request.restarted())
                return
            }

            let isNewHighScore = model.isNewHighScore(result, pastScore: request.pastScore)
            let achievements = model.record(result)
            let run = FinishedRun(
                request: request,
                result: result,
                isNewHighScore: isNewHighScore,
                achievements: achievements,
                nextLevel: model.nextLevel(after: request)
            )
            pendingFinishedRun = run
            DispatchQueue.main.async {
                finishedRun = pendingFinishedRun
                pendingFinishedRun = nil
            }
        }
    }
}

/// A completed, winning run plus everything the results screen needs.
struct FinishedRun: Identifiable, Equatable {
    let request: GameLaunchRequest
    let result: GameResult
    let isNewHighScore: Bool
    let achievements: [Achievement]
    let nextLevel: GameLaunchRequest?

    var id: String { "\(request.id)-\(result.finalScore)" }
}

#Preview("Menu flow — in progress") {
    MenuRootView(model: MenuPreview.inProgressModel())
}

#Preview("Menu flow — fresh save") {
    MenuRootView(model: MenuPreview.freshModel())
}

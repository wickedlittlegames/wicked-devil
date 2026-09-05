import SwiftUI
import WickedDevilCore

/// Every menu screen in one scrollable list, backed by `InMemoryUserDataStore`.
///
/// Shown instead of the game when the app is launched with `-menu-gallery`:
///
/// ```
/// xcrun simctl launch <device> com.wickedlittlewebsites.wickeddevil.swift -menu-gallery YES
/// ```
///
/// It exists so the menus can be inspected on a real device or simulator
/// without touching the save file or playing through to reach a screen — the
/// same job the `#Preview`s do inside Xcode.
struct MenuScreenGallery: View {
    /// Whether this launch asked for the gallery.
    static var isRequested: Bool {
        UserDefaults.standard.bool(forKey: "menu-gallery")
    }

    @State private var model = MenuPreview.inProgressModel()
    @State private var unlocked = MenuPreview.completedModel()

    var body: some View {
        NavigationStack {
            List {
                entry("Title") {
                    TitleView(onPlay: {}, onAdventures: {}, onStore: {}, onStats: {}, onBonusLevel: {})
                        .environment(model)
                }
                entry("World select") {
                    WorldSelectView(onSelectWorld: { _ in }, onStore: {}, onStats: {}, onBack: {})
                        .environment(model)
                }
                entry("Level select") {
                    LevelSelectView(world: 3, onPlay: { _ in }, onStore: {}, onBack: {})
                        .environment(model)
                }
                entry("Adventures (locked)") {
                    AdventureSelectView(onEnterDetective: {}, onStore: {}, onBack: {})
                        .environment(model)
                }
                entry("Detective levels") {
                    DetectiveLevelSelectView(onPlay: { _ in }, onBack: {})
                        .environment(unlocked)
                }
                entry("Store hub") {
                    StoreHubView(onOpen: { _ in }, onBack: {}).environment(model)
                }
                entry("Devil upgrades") {
                    UpgradeShopView(kind: .devil, onBack: {}).environment(model)
                }
                entry("Special upgrades") {
                    UpgradeShopView(kind: .special, onBack: {}).environment(model)
                }
                entry("Characters") {
                    CharacterShopView(onBack: {}).environment(model)
                }
                entry("Soul packs") {
                    SoulShopView(onBack: {}).environment(model)
                }
                entry("Stats") {
                    StatsView(onBack: {}).environment(model)
                }
                entry("Game over") {
                    GameOverView(
                        run: FinishedRun(
                            request: MenuPreview.sampleRequest,
                            result: MenuPreview.sampleResult,
                            isNewHighScore: true,
                            achievements: [.thousandSouls],
                            nextLevel: GameLaunchRequest(world: 2, level: 8)
                        ),
                        onRetry: {},
                        onNext: {},
                        onMenu: {}
                    )
                    .environment(model)
                }
                entry("Gameplay hand-off placeholder") {
                    GameplayPlaceholderView(request: MenuPreview.sampleRequest, finish: { _ in })
                }
            }
            .navigationTitle("Menu gallery")
        }
        .preferredColorScheme(.dark)
    }

    private func entry<Screen: View>(_ title: String, @ViewBuilder screen: @escaping () -> Screen) -> some View {
        NavigationLink(title) {
            screen().toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    MenuScreenGallery()
}

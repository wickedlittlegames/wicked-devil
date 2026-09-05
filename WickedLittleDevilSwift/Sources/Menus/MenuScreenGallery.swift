import SwiftUI
import WickedDevilCore

/// Every menu screen in one place, backed by `InMemoryUserDataStore`.
///
/// Shown instead of the game when the app is launched with `-menu-gallery`:
///
/// ```
/// xcrun simctl launch <device> com.wickedlittlewebsites.wickeddevil.swift \
///     -menu-gallery YES [-menu-gallery-screen stats]
/// ```
///
/// Passing `-menu-gallery-screen <id>` opens that screen directly, which makes
/// the whole set scriptable for screenshots. It exists so the menus can be
/// inspected on a device or simulator without touching the save file or playing
/// through to reach a screen — the same job the `#Preview`s do inside Xcode.
struct MenuScreenGallery: View {
    /// Whether this launch asked for the gallery.
    static var isRequested: Bool {
        UserDefaults.standard.bool(forKey: "menu-gallery")
    }

    /// The screen `-menu-gallery-screen` asked for, if any.
    static var requestedScreen: String? {
        UserDefaults.standard.string(forKey: "menu-gallery-screen")
    }

    @State private var model = MenuPreview.inProgressModel()
    @State private var unlocked = MenuPreview.completedModel()

    private var entries: [Entry] {
        [
            Entry("title", "Title") {
                TitleView(onPlay: {}, onAdventures: {}, onStore: {}, onStats: {}, onBonusLevel: {})
                    .environment(model)
            },
            Entry("worlds", "World select") {
                WorldSelectView(onSelectWorld: { _ in }, onStore: {}, onStats: {}, onBack: {})
                    .environment(model)
            },
            Entry("levels", "Level select") {
                LevelSelectView(world: 3, onPlay: { _ in }, onStore: {}, onBack: {})
                    .environment(model)
            },
            Entry("adventures", "Adventures (locked)") {
                AdventureSelectView(onEnterDetective: {}, onStore: {}, onBack: {})
                    .environment(model)
            },
            Entry("detective", "Detective levels") {
                DetectiveLevelSelectView(onPlay: { _ in }, onBack: {})
                    .environment(unlocked)
            },
            Entry("store", "Store hub") {
                StoreHubView(onOpen: { _ in }, onBack: {}).environment(model)
            },
            Entry("upgrades", "Devil upgrades") {
                UpgradeShopView(kind: .devil, onBack: {}).environment(model)
            },
            Entry("special", "Special upgrades") {
                UpgradeShopView(kind: .special, onBack: {}).environment(model)
            },
            Entry("characters", "Characters") {
                CharacterShopView(onBack: {}).environment(model)
            },
            Entry("souls", "Soul packs") {
                SoulShopView(onBack: {}).environment(model)
            },
            Entry("stats", "Stats") {
                StatsView(onBack: {}).environment(model)
            },
            Entry("gameover", "Game over") {
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
            },
            Entry("handoff", "Gameplay hand-off placeholder") {
                GameplayPlaceholderView(request: MenuPreview.sampleRequest, finish: { _ in })
            },
        ]
    }

    var body: some View {
        Group {
            if let id = Self.requestedScreen, let entry = entries.first(where: { $0.id == id }) {
                entry.screen
            } else {
                NavigationStack {
                    List(entries) { entry in
                        NavigationLink(entry.title) {
                            entry.screen.toolbar(.hidden, for: .navigationBar)
                        }
                    }
                    .navigationTitle("Menu gallery")
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    struct Entry: Identifiable {
        let id: String
        let title: String
        let screen: AnyView

        init<Screen: View>(_ id: String, _ title: String, @ViewBuilder screen: () -> Screen) {
            self.id = id
            self.title = title
            self.screen = AnyView(screen())
        }
    }
}

#Preview {
    MenuScreenGallery()
}

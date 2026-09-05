import SwiftUI
import WickedDevilCore

/// World selection — `WorldSelectScene.m`.
///
/// The original was a `CCScrollLayer` of five full-screen pages (Hell,
/// Underground, Ocean, Earth, "coming soon"), each with an invisible tap target
/// and a `bg-locked.png` overlay when the world was still locked. Rebuilt here
/// as a paged `TabView` so it keeps the swipe-between-worlds feel while working
/// at any screen height.
///
/// Only worlds with actual level content are listed: worlds 5–12 were scoped
/// but never authored, so they collapse into a single "coming soon" card
/// instead of eight empty pages.
struct WorldSelectView: View {
    @Environment(MenuModel.self) private var model

    let onSelectWorld: (Int) -> Void
    let onStore: () -> Void
    let onStats: () -> Void
    let onBack: () -> Void

    @State private var page = 0

    var body: some View {
        MenuScreen(
            title: "Choose a World",
            backgroundImage: currentTheme?.menuBackground ?? "bg-coming-soon",
            souls: model.souls,
            onBack: onBack
        ) {
            VStack(spacing: 12) {
                totals

                TabView(selection: $page) {
                    ForEach(Array(model.worlds.enumerated()), id: \.element.id) { index, world in
                        WorldCard(world: world) { onSelectWorld(world.world) }
                            .tag(index)
                    }
                    if model.inventory.comingSoonWorldCount > 0 {
                        ComingSoonCard(remaining: model.inventory.comingSoonWorldCount)
                            .tag(model.worlds.count)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                HStack(spacing: 12) {
                    Button("Store", action: onStore).devilButton(.quiet)
                    Button("Stats", action: onStats).devilButton(.quiet)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            .onAppear(perform: restoreLastWorld)
        }
    }

    private var currentTheme: WorldTheme? {
        model.worlds.indices.contains(page) ? model.worlds[page].theme : nil
    }

    /// `User.cacheCurrentWorld` remembered which page the scroller opened on.
    private func restoreLastWorld() {
        let cached = model.user.cacheCurrentWorld
        if let index = model.worlds.firstIndex(where: { $0.world == cached }) {
            page = index
        }
    }

    private var totals: some View {
        HStack(spacing: 10) {
            CountPill(
                iconName: "icon-bigcollectable-med",
                fallbackSymbol: "flame.circle.fill",
                text: "\(model.totalAdventureSouls)/\(model.totalAdventureSoulsAvailable)"
            )
            .accessibilityLabel("\(model.totalAdventureSouls) of \(model.totalAdventureSoulsAvailable) big souls")

            CountPill(
                iconName: "icon-halo-med",
                fallbackSymbol: "circle.circle",
                text: "\(model.totalHalos)/\(model.totalHalosAvailable)",
                tint: MenuColor.halo
            )
            .accessibilityLabel("\(model.totalHalos) of \(model.totalHalosAvailable) halos")
        }
        .padding(.top, 8)
    }
}

/// One page of the world carousel.
private struct WorldCard: View {
    let world: WorldSummary
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(MenuColor.panel)
                Image(world.theme.menuBackground)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(world.isUnlocked ? 1 : 0.25)
                    .grayscale(world.isUnlocked ? 0 : 1)

                if !world.isUnlocked {
                    VStack(spacing: 8) {
                        Image(systemName: "lock.fill").font(.system(size: 34, weight: .bold))
                        Text("Beat World \(world.world - 1)")
                            .font(.devilBody(16))
                    }
                    .foregroundStyle(MenuColor.text)
                    .padding(20)
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(MenuColor.panelStroke.opacity(0.7), lineWidth: 2)
            )

            VStack(spacing: 6) {
                Text("World \(world.world)")
                    .font(.devilCaption(14))
                    .foregroundStyle(MenuColor.mutedText)
                Text(world.theme.name)
                    .font(.devilTitle(34))
                    .foregroundStyle(MenuColor.soul)
            }

            HStack(spacing: 8) {
                CountPill(
                    iconName: "icon-bigcollectable-med",
                    fallbackSymbol: "flame.circle.fill",
                    text: "\(world.soulsEarned)/\(world.soulsAvailable)"
                )
                CountPill(
                    iconName: "icon-halo-med",
                    fallbackSymbol: "circle.circle",
                    text: "\(world.halosEarned)/\(world.halosAvailable)",
                    tint: MenuColor.halo
                )
            }

            Text("\(world.completedLevels)/\(world.levelCount) levels · best \(world.highScore.formatted(.number))")
                .font(.devilCaption(14))
                .foregroundStyle(MenuColor.mutedText)

            Button(world.isUnlocked ? "Enter" : "Locked", action: onPlay)
                .devilButton(world.isUnlocked ? .primary : .secondary, enabled: world.isUnlocked)
                .disabled(!world.isUnlocked)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 8)
    }
}

/// Worlds 5–12 were designed but never built.
private struct ComingSoonCard: View {
    let remaining: Int

    var body: some View {
        VStack(spacing: 16) {
            Image("bg-coming-soon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(MenuColor.panelStroke.opacity(0.7), lineWidth: 2)
                )

            Text("Coming Soon")
                .font(.devilTitle(34))
                .foregroundStyle(MenuColor.soul)

            Text("\(remaining) more worlds were planned for Wicked Little Devil but never finished.")
                .font(.devilBody(16))
                .foregroundStyle(MenuColor.mutedText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 8)
    }
}

#Preview("World select — in progress") {
    NavigationStack {
        WorldSelectView(onSelectWorld: { _ in }, onStore: {}, onStats: {}, onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("World select — fresh save") {
    NavigationStack {
        WorldSelectView(onSelectWorld: { _ in }, onStore: {}, onStats: {}, onBack: {})
            .environment(MenuPreview.freshModel())
    }
    .preferredColorScheme(.dark)
}

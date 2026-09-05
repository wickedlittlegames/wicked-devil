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
            backgroundImage: currentTheme?.levelBackground ?? "bg-coming-soon",
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
                // The built-in indicator floats over the bottom of the page and
                // would sit on top of the Enter button, so it is drawn below.
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageDots

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

    private var pageDots: some View {
        let count = model.worlds.count + (model.inventory.comingSoonWorldCount > 0 ? 1 : 0)
        return HStack(spacing: 8) {
            ForEach(0..<max(count, 1), id: \.self) { index in
                Circle()
                    .fill(index == page ? MenuColor.text : MenuColor.mutedText.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .accessibilityHidden(true)
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
///
/// The original world art is a full-screen poster with the world's name
/// lettered into it, so it is shown whole (`.fit`) rather than cropped to a
/// banner, and the name is not repeated as text underneath.
private struct WorldCard: View {
    let world: WorldSummary
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            poster

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

    private var poster: some View {
        ZStack {
            Image(world.theme.menuBackground)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(world.isUnlocked ? 1 : 0.3)
                .grayscale(world.isUnlocked ? 0 : 1)

            if !world.isUnlocked {
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill").font(.system(size: 34, weight: .bold))
                    Text("World \(world.world)")
                        .font(.devilTitle(30))
                        .foregroundStyle(MenuColor.soul)
                    Text("Beat World \(world.world - 1)")
                        .font(.devilBody(16))
                }
                .foregroundStyle(MenuColor.text)
                .padding(20)
                .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(MenuColor.panelStroke.opacity(0.7), lineWidth: 2)
        )
    }
}

/// Worlds 5–12 were designed but never built.
private struct ComingSoonCard: View {
    let remaining: Int

    var body: some View {
        VStack(spacing: 16) {
            Image("bg-coming-soon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(MenuColor.panelStroke.opacity(0.7), lineWidth: 2)
                )

            Text("\(remaining) more worlds were planned for Wicked Little Devil but never finished.")
                .font(.devilBody(16))
                .foregroundStyle(MenuColor.mutedText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
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

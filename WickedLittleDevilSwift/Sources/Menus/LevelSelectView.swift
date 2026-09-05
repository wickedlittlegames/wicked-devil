import SwiftUI
import WickedDevilCore

/// Level grid for one world — `LevelSelectScene.m`.
///
/// The original laid 20 fixed buttons out 4-per-row on a `bg-world-N.png`
/// backdrop, each showing 0–3 soul pips and a halo icon, with locked levels
/// swapped for `btn-level-locked.png`. This version derives the grid from the
/// level inventory, so a world with fewer than 20 authored levels renders
/// correctly.
struct LevelSelectView: View {
    @Environment(MenuModel.self) private var model

    let world: Int
    let onPlay: (Int) -> Void
    let onStore: () -> Void
    let onBack: () -> Void

    @State private var skipAlert: SkipAlert?

    private var summary: WorldSummary? {
        model.worlds.first { $0.world == world }
    }

    var body: some View {
        let theme = WorldTheme.theme(for: world)
        MenuScreen(
            title: theme.name,
            backgroundImage: theme.levelBackground,
            souls: model.souls,
            onBack: onBack
        ) {
            VStack(spacing: 14) {
                totals
                    .padding(.horizontal, 18)
                    .padding(.top, 12)

                ScrollView {
                    grid
                        .padding(.horizontal, 18)
                        .padding(.vertical, 4)
                }
                .scrollBounceBehavior(.basedOnSize)

                if model.canSkip(world: world) {
                    skipButton
                        .padding(.horizontal, 18)
                        .padding(.bottom, 8)
                }
            }
            .containerRelativeFrame(.horizontal)
        }
        .alert(item: $skipAlert) { alert in
            switch alert {
            case .confirm:
                return Alert(
                    title: Text("Skip this level?"),
                    message: Text("Unlocks the next level for \(model.skipCost.formatted(.number)) souls."),
                    primaryButton: .destructive(Text("Skip")) { performSkip() },
                    secondaryButton: .cancel()
                )
            case .notEnough(let shortfall):
                return Alert(
                    title: Text("Not Enough Souls!"),
                    message: Text("You need \(shortfall.formatted(.number)) more souls to skip a level."),
                    primaryButton: .default(Text("Visit Store")) { onStore() },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private var totals: some View {
        HStack(spacing: 10) {
            CountPill(
                iconName: "icon-bigcollectable-med",
                fallbackSymbol: "flame.circle.fill",
                text: "\(summary?.soulsEarned ?? 0)/\(summary?.soulsAvailable ?? 0)"
            )
            CountPill(
                iconName: "icon-halo-med",
                fallbackSymbol: "circle.circle",
                text: "\(summary?.halosEarned ?? 0)/\(summary?.halosAvailable ?? 0)",
                tint: MenuColor.halo
            )
            Spacer(minLength: 4)
            Text("Best \((summary?.highScore ?? 0).formatted(.number))")
                .font(.devilBody(16))
                .foregroundStyle(MenuColor.mutedText)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
            spacing: 12
        ) {
            ForEach(summary?.levels ?? []) { level in
                LevelTile(level: level) { onPlay(level.level) }
            }
        }
    }

    private var skipButton: some View {
        Button {
            skipAlert = model.canAfford(model.skipCost)
                ? .confirm
                : .notEnough(shortfall: model.skipCost - model.souls)
        } label: {
            HStack {
                Image(systemName: "forward.fill")
                Text("Skip level")
                Spacer()
                Text(model.skipCost.formatted(.number)).monospacedDigit()
            }
        }
        .devilButton(.secondary, enabled: model.canAfford(model.skipCost))
    }

    private func performSkip() {
        if case .notEnoughSouls(let shortfall) = model.buyLevelSkip() {
            skipAlert = .notEnough(shortfall: shortfall)
        }
    }

    enum SkipAlert: Identifiable {
        case confirm
        case notEnough(shortfall: Int)

        var id: String {
            switch self {
            case .confirm: return "confirm"
            case .notEnough(let shortfall): return "short-\(shortfall)"
            }
        }
    }
}

/// One level button: number, soul pips and halo, or a padlock.
struct LevelTile: View {
    let level: LevelSummary
    var monochrome = false
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            VStack(spacing: 4) {
                if level.isUnlocked {
                    Text("\(level.level)")
                        .font(.devilHeading(24))
                        .foregroundStyle(
                            monochrome ? MenuColor.text : MenuColor.levelNumber(world: level.world)
                        )
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(MenuColor.locked)
                }

                HStack(spacing: 4) {
                    SoulPips(earned: level.soulsEarned, monochrome: monochrome)
                    if level.halosEarned > 0 {
                        Image(systemName: "circle.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(MenuColor.halo)
                    }
                }
                .opacity(level.isUnlocked ? 1 : 0.25)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(tileBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        level.isUnlocked ? MenuColor.panelStroke : MenuColor.locked.opacity(0.5),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!level.isUnlocked)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder private var tileBackground: some View {
        if level.isUnlocked {
            LinearGradient(
                colors: monochrome
                    ? [Color(white: 0.85), Color(white: 0.62)]
                    : [MenuColor.soul, MenuColor.ember.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.black.opacity(0.5)
        }
    }

    private var accessibilityLabel: String {
        guard level.isUnlocked else { return "Level \(level.level), locked" }
        let halo = level.halosEarned > 0 ? ", halo found" : ""
        return "Level \(level.level), \(level.soulsEarned) of 3 souls\(halo)"
    }
}

#Preview("Level select — world 1") {
    NavigationStack {
        LevelSelectView(world: 1, onPlay: { _ in }, onStore: {}, onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Level select — world 3, partly done") {
    NavigationStack {
        LevelSelectView(world: 3, onPlay: { _ in }, onStore: {}, onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

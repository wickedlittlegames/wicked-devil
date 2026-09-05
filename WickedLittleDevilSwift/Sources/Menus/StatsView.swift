import SwiftUI
import WickedDevilCore

/// Player statistics and achievements — `StatsScene.m`.
///
/// The original showed eight rows (its "Facebook Active" row is dropped along
/// with the rest of the Facebook integration, and its "Jumps" row was commented
/// out in the shipped source — it is restored here since `User` tracks it).
struct StatsView: View {
    @Environment(MenuModel.self) private var model

    let onBack: () -> Void

    @State private var confirmingReset = false

    var body: some View {
        MenuScreen(
            title: "Stats",
            backgroundImage: "bg-stats-iphone5",
            souls: model.souls,
            onBack: onBack
        ) {
            ScrollView {
                VStack(spacing: 14) {
                    statsPanel
                    achievementsPanel
                    Button("Reset progress", role: .destructive) { confirmingReset = true }
                        .devilButton(.quiet)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
        }
        .alert("Reset progress?", isPresented: $confirmingReset) {
            Button("Reset", role: .destructive) { model.resetProfile() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Souls, unlocks, purchases, scores and achievements will all be wiped. This cannot be undone.")
        }
    }

    private var statsPanel: some View {
        MenuPanel {
            VStack(spacing: 0) {
                row("Total Score", model.totalScore.formatted(.number))
                row("Big Souls", "\(model.totalAdventureSouls)/\(model.totalAdventureSoulsAvailable)")
                row("Small Souls", model.souls.formatted(.number))
                row("Halos", "\(model.totalHalos)/\(model.totalHalosAvailable)")
                row("World Progress", "\(min(model.worldProgress, GameConstants.currentWorldsPerGame))/\(GameConstants.currentWorldsPerGame)")
                row("Level Progress", "\(model.levelProgress)/\(GameConstants.levelsPerWorld)")
                row("Deaths", model.deaths.formatted(.number))
                row("Jumps", model.jumps.formatted(.number))
                row("Detective", model.unlockedDetective ? "Unlocked" : "Locked", isLast: true)
            }
        }
    }

    private var achievementsPanel: some View {
        MenuPanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Achievements").font(.devilHeading(22))
                    Spacer()
                    Text("\(model.unlockedAchievements.count)/\(Achievement.allCases.count)")
                        .font(.devilBody(16))
                        .foregroundStyle(MenuColor.mutedText)
                        .monospacedDigit()
                }

                ForEach(Achievement.allCases, id: \.self) { achievement in
                    AchievementRow(
                        achievement: achievement,
                        isUnlocked: model.unlockedAchievements.contains(achievement)
                    )
                }
            }
        }
    }

    private func row(_ title: String, _ value: String, isLast: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).font(.devilBody(17)).foregroundStyle(MenuColor.mutedText)
                Spacer()
                Text(value).font(.devilBody(19)).monospacedDigit()
            }
            .padding(.vertical, 9)

            if !isLast {
                Divider().overlay(MenuColor.panelStroke.opacity(0.4))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isUnlocked ? "checkmark.seal.fill" : "seal")
                .font(.system(size: 18))
                .foregroundStyle(isUnlocked ? MenuColor.soul : MenuColor.locked)

            VStack(alignment: .leading, spacing: 1) {
                Text(achievement.title).font(.devilBody(16))
                Text(achievement.detail)
                    .font(.devilCaption(13))
                    .foregroundStyle(MenuColor.mutedText)
            }

            Spacer(minLength: 0)
        }
        .opacity(isUnlocked ? 1 : 0.55)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title), \(isUnlocked ? "unlocked" : "locked"). \(achievement.detail)")
    }
}

/// Presentation copy for the achievements `User` tracks. The original strings
/// lived in iTunes Connect / Game Center rather than the source, so these are
/// written from each achievement's unlock condition in `User.checkAchievements`.
extension Achievement {
    var title: String {
        switch self {
        case .firstPlay: return "Welcome to Hell"
        case .collected666Souls: return "Number of the Beast"
        case .thousandSouls: return "Soul Collector"
        case .fiveThousandSouls: return "Soul Trader"
        case .tenThousandSouls: return "Soul Baron"
        case .fiftyThousandSouls: return "Soul Tycoon"
        case .beatWorld1: return "Hell Conquered"
        case .beatWorld2: return "Underground Conquered"
        case .beatWorld3: return "Ocean Conquered"
        case .beatWorld4: return "Earth Conquered"
        case .killed: return "Killed by Death"
        case .died100: return "Glutton for Punishment"
        case .jumped1000: return "Spring Heeled"
        case .halo: return "Saintly"
        }
    }

    var detail: String {
        switch self {
        case .firstPlay: return "Play your first level."
        case .collected666Souls: return "Hold \(GameConstants.Threshold.souls666) souls."
        case .thousandSouls: return "Hold \(GameConstants.Threshold.souls1000.formatted(.number)) souls."
        case .fiveThousandSouls: return "Hold \(GameConstants.Threshold.souls5000.formatted(.number)) souls."
        case .tenThousandSouls: return "Hold \(GameConstants.Threshold.souls10000.formatted(.number)) souls."
        case .fiftyThousandSouls: return "Hold \(GameConstants.Threshold.souls50000.formatted(.number)) souls."
        case .beatWorld1: return "Finish every level in world 1."
        case .beatWorld2: return "Finish every level in world 2."
        case .beatWorld3: return "Finish every level in world 3."
        case .beatWorld4: return "Finish every level in world 4."
        case .killed: return "Be killed by Death itself."
        case .died100: return "Die \(GameConstants.Threshold.deaths100) times."
        case .jumped1000: return "Make \(GameConstants.Threshold.jumps1000.formatted(.number)) platform jumps."
        case .halo: return "Find all \(GameConstants.Threshold.halosAll) halos."
        }
    }
}

#Preview("Stats — in progress") {
    NavigationStack {
        StatsView(onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Stats — fresh save") {
    NavigationStack {
        StatsView(onBack: {})
            .environment(MenuPreview.freshModel())
    }
    .preferredColorScheme(.dark)
}

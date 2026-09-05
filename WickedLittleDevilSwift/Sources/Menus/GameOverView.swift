import SwiftUI
import WickedDevilCore

/// End-of-run results — `Scenes/Gameplay/GameOverScene.m`.
///
/// The original tallied the score in stages with a sound per stage:
/// SOUL BONUS (big souls × 1,000) → TIME BONUS (seconds remaining × 100, hidden
/// when the timer ran out) → COLLECTED BONUS (small souls × the level's points
/// per collectable, hidden when zero) → SCORE. `ui-newhighscore` was stamped on
/// top when the run beat the stored best.
///
/// Only *winning* runs reach this screen: `GameLayer.m end:` restarted the
/// level on a death instead of pushing the results scene.
struct GameOverView: View {
    @Environment(MenuModel.self) private var model

    let run: FinishedRun
    let onRetry: () -> Void
    let onNext: () -> Void
    let onMenu: () -> Void

    /// How many breakdown rows have been revealed so far.
    @State private var revealed = 0
    @State private var showsTip = false

    private var rows: [BreakdownRow] {
        var rows: [BreakdownRow] = [
            BreakdownRow(title: "Soul Bonus", value: run.result.soulsScore)
        ]
        if run.result.timeBonus > 0 {
            rows.append(BreakdownRow(title: "Time Bonus", value: run.result.timeBonusScore))
        }
        if run.result.collectableScore > 0 {
            rows.append(BreakdownRow(title: "Collected Bonus", value: run.result.collectableScore))
        }
        return rows
    }

    var body: some View {
        ZStack {
            MenuBackground("bg-gameover", dim: 0.45)

            VStack(spacing: 16) {
                Spacer(minLength: 0)

                Text("Level Complete")
                    .font(.devilTitle(38))
                    .multilineTextAlignment(.center)

                if run.isNewHighScore { highScoreBanner }

                MenuPanel {
                    VStack(spacing: 0) {
                        ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                            breakdown(row.title, row.value)
                                .opacity(index < revealed ? 1 : 0)
                        }

                        Divider().overlay(MenuColor.panelStroke).padding(.vertical, 6)

                        breakdown("Score", run.result.finalScore, emphasised: true)
                            .opacity(revealed > rows.count ? 1 : 0)
                    }
                }

                pickups

                if !run.achievements.isEmpty { achievements }

                Spacer(minLength: 0)

                buttons
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
            .foregroundStyle(MenuColor.text)
        }
        .task { await revealScore() }
        .alert("Running low on souls?", isPresented: $showsTip) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You have \(model.souls.formatted(.number)) souls. Spend them on upgrades in the store to make the next levels easier.")
        }
    }

    private var highScoreBanner: some View {
        Group {
            if UIImage(named: "ui-newhighscore") != nil {
                Image("ui-newhighscore").resizable().scaledToFit().frame(height: 34)
            } else {
                Text("New Highscore!")
                    .font(.devilHeading(22))
                    .foregroundStyle(MenuColor.soul)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.45), in: Capsule())
            }
        }
        .transition(.scale.combined(with: .opacity))
    }

    private var pickups: some View {
        HStack(spacing: 10) {
            CountPill(
                iconName: "icon-bigcollectable-med",
                fallbackSymbol: "flame.circle.fill",
                text: "\(run.result.bigCollected)/3"
            )
            if !run.request.isDetectiveLevel {
                CountPill(
                    iconName: "icon-halo-med",
                    fallbackSymbol: "circle.circle",
                    text: run.result.haloCollected > 0 ? "Found" : "Missed",
                    tint: MenuColor.halo
                )
            }
            CountPill(
                iconName: "ui-collectable",
                fallbackSymbol: "flame.fill",
                text: run.result.collected.formatted(.number)
            )
        }
    }

    private var achievements: some View {
        MenuPanel {
            VStack(alignment: .leading, spacing: 6) {
                Text("Achievement unlocked")
                    .font(.devilCaption(14))
                    .foregroundStyle(MenuColor.mutedText)
                ForEach(run.achievements, id: \.self) { achievement in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(MenuColor.soul)
                        Text(achievement.title).font(.devilBody(17))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var buttons: some View {
        VStack(spacing: 10) {
            if run.nextLevel != nil {
                Button("Next", action: onNext).devilButton()
            }
            Button("Retry", action: onRetry).devilButton(.secondary)
            Button("Menu", action: onMenu).devilButton(.quiet)
        }
    }

    private func breakdown(_ title: String, _ value: Int, emphasised: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(emphasised ? .devilHeading(24) : .devilBody(18))
                .foregroundStyle(emphasised ? MenuColor.text : MenuColor.mutedText)
            Spacer()
            Text(value.formatted(.number))
                .font(emphasised ? .devilHeading(26) : .devilBody(20))
                .foregroundStyle(emphasised ? MenuColor.soul : MenuColor.text)
                .monospacedDigit()
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value)")
    }

    /// Staggered reveal standing in for the original's per-stage `SimpleAudio`
    /// beats and `CCDelayTime` sequence.
    private func revealScore() async {
        for step in 0...(rows.count + 1) where step > revealed {
            try? await Task.sleep(for: .milliseconds(340))
            withAnimation(.easeOut(duration: 0.2)) { revealed = step }
        }
        // `GameOverScene.m` nudged the player towards the upgrade store once
        // they had enough souls to actually buy something worthwhile.
        if model.souls >= 2000 { showsTip = true }
    }

    private struct BreakdownRow: Identifiable {
        let title: String
        let value: Int
        var id: String { title }
    }
}

#Preview("Game over — new high score") {
    GameOverView(
        run: FinishedRun(
            request: MenuPreview.sampleRequest,
            result: MenuPreview.sampleResult,
            isNewHighScore: true,
            achievements: [.thousandSouls],
            nextLevel: GameLaunchRequest(world: 1, level: 4)
        ),
        onRetry: {},
        onNext: {},
        onMenu: {}
    )
    .environment(MenuPreview.inProgressModel())
    .preferredColorScheme(.dark)
}

#Preview("Game over — last level") {
    GameOverView(
        run: FinishedRun(
            request: MenuPreview.sampleRequest,
            result: MenuPreview.sampleResult,
            isNewHighScore: false,
            achievements: [],
            nextLevel: nil
        ),
        onRetry: {},
        onNext: {},
        onMenu: {}
    )
    .environment(MenuPreview.freshModel())
    .preferredColorScheme(.dark)
}

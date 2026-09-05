import SwiftUI
import WickedDevilCore

/// The title screen — `StartScene.m`.
///
/// Dropped from the original: the Facebook login, the Parse leaderboard, the
/// PlayHaven "more games" cross-promo, and the `user.collected += 1000000`
/// debug cheat that ran on every launch.
///
/// The hidden bonus level is kept but re-gated. The original hid World 11 in a
/// pull-down drawer that unlocked once the player "liked" the game's Facebook
/// page. With Facebook gone, it is now a genuine secret: long-press the title
/// to reveal the drawer.
struct TitleView: View {
    @Environment(MenuModel.self) private var model

    let onPlay: () -> Void
    let onAdventures: () -> Void
    let onStore: () -> Void
    let onStats: () -> Void
    let onBonusLevel: () -> Void

    @State private var showSecretDrawer = false

    var body: some View {
        ZStack {
            MenuBackground("bg-home-iphone5", dim: 0.2)

            VStack(spacing: 0) {
                header
                Spacer(minLength: 12)
                title
                Spacer(minLength: 12)
                buttons
                if showSecretDrawer, model.bonusLevel != nil {
                    secretDrawer
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .foregroundStyle(MenuColor.text)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSecretDrawer)
    }

    private var header: some View {
        HStack {
            SoulsBadge(souls: model.souls)
            Spacer()
            Button {
                model.toggleMute()
            } label: {
                Image(systemName: model.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 16, weight: .bold))
                    .padding(10)
                    .background(Color.black.opacity(0.45), in: Circle())
            }
            .accessibilityLabel(model.isMuted ? "Unmute" : "Mute")
        }
        .padding(.top, 8)
    }

    private var title: some View {
        VStack(spacing: 2) {
            Text("Wicked")
                .font(.devilTitle(52))
                .foregroundStyle(MenuColor.soul)
            Text("Little Devil")
                .font(.devilTitle(44))
                .foregroundStyle(MenuColor.ember)
        }
        .shadow(color: .black.opacity(0.8), radius: 8, y: 4)
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Wicked Little Devil")
        .accessibilityAddTraits(.isHeader)
        .onLongPressGesture(minimumDuration: 1.2) {
            guard model.bonusLevel != nil else { return }
            showSecretDrawer.toggle()
        }
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button("Play", action: onPlay)
                .devilButton()

            Button {
                onAdventures()
            } label: {
                HStack {
                    Text("Adventures")
                    if !model.unlockedDetective {
                        Spacer()
                        Image(systemName: "lock.fill").font(.system(size: 14, weight: .bold))
                    }
                }
            }
            .devilButton(.secondary)

            HStack(spacing: 12) {
                Button("Store", action: onStore).devilButton(.quiet)
                Button("Stats", action: onStats).devilButton(.quiet)
            }
        }
    }

    /// `StartScene.m` line ~171: the world-11 bonus level.
    private var secretDrawer: some View {
        MenuPanel {
            VStack(spacing: 10) {
                Text("A secret level")
                    .font(.devilHeading(20))
                Text("World \(GameConstants.bonusWorld) · Level \(GameConstants.bonusLevel)")
                    .font(.devilCaption(14))
                    .foregroundStyle(MenuColor.mutedText)
                if let bonus = model.bonusLevel {
                    SoulPips(earned: bonus.soulsEarned)
                }
                Button("Play the bonus level", action: onBonusLevel)
                    .devilButton()
            }
        }
        .padding(.top, 16)
    }
}

#Preview("Title — in progress") {
    TitleView(onPlay: {}, onAdventures: {}, onStore: {}, onStats: {}, onBonusLevel: {})
        .environment(MenuPreview.inProgressModel())
}

#Preview("Title — fresh save") {
    TitleView(onPlay: {}, onAdventures: {}, onStore: {}, onStats: {}, onBonusLevel: {})
        .environment(MenuPreview.freshModel())
}

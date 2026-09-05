import SwiftUI
import WickedDevilCore

/// The "Adventures" hub — `AdventureSelectScene.m`.
///
/// In the original this was a second entry point from the title screen that led
/// only to the Detective Devil campaign (pseudo-world 20), gated behind a
/// `DETECTIVE_UNLOCK_COST` (15,000) soul purchase. Everything else on that
/// scene was Facebook-related and is dropped.
struct AdventureSelectView: View {
    @Environment(MenuModel.self) private var model

    let onEnterDetective: () -> Void
    let onStore: () -> Void
    let onBack: () -> Void

    @State private var notEnoughSouls: Int?

    var body: some View {
        MenuScreen(
            title: "Adventures",
            backgroundImage: "bg-store-iphone5",
            souls: model.souls,
            onBack: onBack
        ) {
            VStack(spacing: 20) {
                Spacer(minLength: 0)
                detectiveCard
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 24)
        }
        .alert(
            "Not Enough Souls!",
            isPresented: Binding(get: { notEnoughSouls != nil }, set: { if !$0 { notEnoughSouls = nil } })
        ) {
            Button("Visit Store") { onStore() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You need \((notEnoughSouls ?? 0).formatted(.number)) more souls to unlock the Detective.")
        }
    }

    private var detectiveCard: some View {
        MenuPanel {
            VStack(spacing: 14) {
                ZStack {
                    Image("bg-menu-detective")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 190)
                        .clipped()
                        .grayscale(model.unlockedDetective ? 0 : 1)
                        .opacity(model.unlockedDetective ? 1 : 0.4)

                    if !model.unlockedDetective {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(MenuColor.text)
                            .shadow(radius: 6)
                    }
                }
                .frame(height: 190)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text("Detective Devil")
                    .font(.devilTitle(32))
                    .foregroundStyle(MenuColor.text)

                Text("A black-and-white side story: \(model.detective?.levelCount ?? 0) levels the Devil solves in a past life.")
                    .font(.devilBody(15))
                    .foregroundStyle(MenuColor.mutedText)
                    .multilineTextAlignment(.center)

                if model.unlockedDetective {
                    if let detective = model.detective {
                        HStack(spacing: 8) {
                            CountPill(
                                iconName: "icon-bigcollectable-med-bw",
                                fallbackSymbol: "flame.circle.fill",
                                text: "\(detective.soulsEarned)/\(detective.soulsAvailable)",
                                tint: MenuColor.mutedText
                            )
                            Text("Best \(detective.highScore.formatted(.number))")
                                .font(.devilCaption(14))
                                .foregroundStyle(MenuColor.mutedText)
                                .monospacedDigit()
                        }
                    }
                    Button("Enter", action: onEnterDetective).devilButton()
                } else {
                    Button {
                        unlock()
                    } label: {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Unlock")
                            Spacer()
                            Text(model.detectiveUnlockCost.formatted(.number)).monospacedDigit()
                        }
                    }
                    .devilButton(.primary, enabled: model.canAfford(model.detectiveUnlockCost))
                }
            }
        }
    }

    private func unlock() {
        if case .notEnoughSouls(let shortfall) = model.unlockDetective() {
            notEnoughSouls = shortfall
        }
    }
}

#Preview("Adventures — locked") {
    NavigationStack {
        AdventureSelectView(onEnterDetective: {}, onStore: {}, onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Adventures — unlocked") {
    NavigationStack {
        AdventureSelectView(onEnterDetective: {}, onStore: {}, onBack: {})
            .environment(MenuPreview.completedModel())
    }
    .preferredColorScheme(.dark)
}

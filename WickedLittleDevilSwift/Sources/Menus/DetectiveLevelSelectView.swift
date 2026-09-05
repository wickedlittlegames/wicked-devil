import SwiftUI
import WickedDevilCore

/// The Detective Devil level grid — `DetectiveLevelSelectScene.m`.
///
/// The campaign is stored as pseudo-world 20, with its own high-score and soul
/// arrays and no halos. Access is gated once, on `AdventureSelectView`; every
/// level here is playable from the moment the campaign is bought, exactly as
/// the original did (`isEnabled = TRUE` for the whole grid).
///
/// `GameConstants.detectiveLevelCount` claims 12 levels, but only 10 `.ccbi`
/// files were ever authored and converted, so the grid follows the inventory.
struct DetectiveLevelSelectView: View {
    @Environment(MenuModel.self) private var model

    let onPlay: (Int) -> Void
    let onBack: () -> Void

    var body: some View {
        MenuScreen(
            title: "Detective Devil",
            backgroundImage: "bg-world-20",
            souls: model.souls,
            monochrome: true,
            onBack: onBack
        ) {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    grid
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .grayscale(0.85)
    }

    private var header: some View {
        HStack(spacing: 10) {
            CountPill(
                iconName: "icon-bigcollectable-med-bw",
                fallbackSymbol: "flame.circle.fill",
                text: "\(model.detective?.soulsEarned ?? 0)/\(model.detective?.soulsAvailable ?? 0)",
                tint: MenuColor.mutedText
            )
            Spacer()
            Text("Best \((model.detective?.highScore ?? 0).formatted(.number))")
                .font(.devilBody(16))
                .foregroundStyle(MenuColor.mutedText)
                .monospacedDigit()
        }
    }

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
            spacing: 12
        ) {
            ForEach(model.detective?.levels ?? []) { level in
                LevelTile(level: level, monochrome: true) { onPlay(level.level) }
            }
        }
    }
}

#Preview("Detective levels") {
    NavigationStack {
        DetectiveLevelSelectView(onPlay: { _ in }, onBack: {})
            .environment(MenuPreview.completedModel())
    }
    .preferredColorScheme(.dark)
}

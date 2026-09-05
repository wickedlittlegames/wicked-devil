import SwiftUI
import WickedDevilCore

/// The app's real entry point: the menus, with the SpriteKit gameplay layer
/// plugged into the hand-off contract.
///
/// Everything either side of the contract is deliberately unaware of the other:
///
/// * `MenuRootView` owns navigation, the profile and all persistence.
/// * `GameplayLauncher.spriteKit(user:)` (defined in `Sources/Gameplay`) builds
///   the SpriteKit run for a `GameLaunchRequest` and reports back a
///   `GameResult?`.
///
/// Swap the launcher for `.placeholder` to exercise the whole menu flow without
/// gameplay — see `GameplayHandoff.swift`.
struct MenuHostView: View {
    @State private var model = MenuModel()

    var body: some View {
        MenuRootView(model: model)
            .environment(\.gameplayLauncher, .spriteKit(user: model.user))
    }
}

#Preview("Menus with placeholder gameplay") {
    MenuRootView(model: MenuPreview.inProgressModel())
        .environment(\.gameplayLauncher, .placeholder)
}

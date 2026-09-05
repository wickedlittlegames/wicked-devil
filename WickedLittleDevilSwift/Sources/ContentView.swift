import SwiftUI
import WickedDevilCore

/// The app's root.
///
/// The menu layer owns the real entry point: `MenuHostView` presents the title
/// screen and hands each chosen level to the SpriteKit scene through
/// `GameplayHandoff`. `DirectLevelHarnessView` below is kept as a one-line
/// swap for exercising the gameplay loop on its own.
struct ContentView: View {
    var body: some View {
        MenuHostView()
    }
}

/// Launches straight into a playable level, bypassing the menus.
///
/// Useful while iterating on gameplay: it drops the player into world 1 level 1
/// and continues (or replays) when a run ends.
struct DirectLevelHarnessView: View {
    @State private var request = GameLaunchRequest(world: 1, level: 1)
    @State private var runToken = 0
    @State private var user = User(store: UserDefaultsUserDataStore())

    var body: some View {
        GameplayHostView(request: request, user: user) { result in
            advance(after: result)
        }
        // Forces a fresh scene for each run.
        .id("\(request.id)-\(runToken)")
    }

    private func advance(after result: GameResult?) {
        guard let result else { return }
        if result.didWin {
            _ = user.recordCompletedLevel(result)
        }
        runToken += 1
        request = result.didWin
            ? GameLaunchRequest(world: request.world, level: request.level + 1)
            : request.restarted()
    }
}

#Preview {
    ContentView()
}

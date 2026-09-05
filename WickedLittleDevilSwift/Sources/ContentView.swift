import SpriteKit
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var scene = GameScene(size: UIScreen.main.bounds.size)

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .task {
                scene.scaleMode = .resizeFill
            }
    }
}

#Preview {
    ContentView()
}

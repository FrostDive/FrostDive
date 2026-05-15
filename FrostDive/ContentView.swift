import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @StateObject private var state = gameState()
    var scene: gameScene {
        let scene = gameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        scene.gameState = state
        return scene
    }

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: makeScene(size: geometry.size))
                .ignoresSafeArea()
        }
    }

    private func makeScene(size: CGSize) -> SKScene {
        let scene = homeScene(size: size)
        scene.scaleMode = .resizeFill
        return scene
    }
}

#Preview {
    ContentView()
}

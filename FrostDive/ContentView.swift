import SwiftUI
import SpriteKit
import UIKit

enum SceneSizeProvider {
    static var current: CGSize {
        current(for: nil)
    }

    static func current(for view: SKView?) -> CGSize {
        if let size = view?.bounds.size, size.width > 1, size.height > 1 {
            return size
        }

        if let screen = view?.window?.windowScene?.screen {
            return screen.bounds.size
        }

        if let screen = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.screen })
            .first {
            return screen.bounds.size
        }

        return UIScreen.main.bounds.size
    }
}

final class SceneHostSKView: SKView {
    var gameStateRef: gameState?
    private var hasPresentedInitialScene = false

    override func didMoveToWindow() {
        super.didMoveToWindow()

        DispatchQueue.main.async { [weak self] in
            self?.presentInitialSceneIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        presentInitialSceneIfNeeded()
    }

    private func presentInitialSceneIfNeeded() {
        guard !hasPresentedInitialScene,
              let gameStateRef else {
            return
        }

        let sceneSize = SceneSizeProvider.current(for: self)
        guard sceneSize.width > 1, sceneSize.height > 1 else {
            return
        }

        hasPresentedInitialScene = true

        let scene = homeScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        scene.gameStateRef = gameStateRef
        presentScene(scene)
    }
}

struct ContentView: View {

    @StateObject private var gs = gameState()
    @StateObject private var ps = playerStats()

    var body: some View {
        ZStack {
            SceneHostView(gameState: gs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            if gs.isPaused {
                pause(gameState: gs)
            }

            if gs.isGameOver {
                gameOver(gameState: gs, playerStats: ps)
            }
        }
    }
}

struct SceneHostView: UIViewRepresentable {
    let gameState: gameState

    func makeUIView(context: Context) -> SKView {
        let skView = SceneHostSKView()
        skView.gameStateRef = gameState
        skView.ignoresSiblingOrder = true
        skView.isUserInteractionEnabled = true
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        let frozen = gameState.isPaused || gameState.isGameOver
        uiView.scene?.speed = frozen ? 0 : 1
        uiView.scene?.physicsWorld.speed = frozen ? 0 : 1
    }
}

#Preview {
    ContentView()
}

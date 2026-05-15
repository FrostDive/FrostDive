//
//  ContentView.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 12/05/26.
//

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
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

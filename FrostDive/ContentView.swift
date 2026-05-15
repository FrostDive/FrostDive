//
//  ContentView.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 12/05/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject var game_state = gameState()
    @StateObject var player_stats = playerStats()

    var body: some View {
        gameOver(gameState: game_state, playerStats: player_stats)
        .edgesIgnoringSafeArea(.all)
    }
}

//struct ContentView: View {
//    var scene: SKScene {
//        let scene = gameScene(size: UIScreen.main.bounds.size)
//        scene.scaleMode = .aspectFill
//        return scene
//    }
//
//    var body: some View {
//        SpriteView(scene: scene)
//            .ignoresSafeArea()
//    }
//}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 12/05/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = gameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill // ✅ Pastikan scaleMode-nya aspectFill atau resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea() // ✅ Ini kunci agar bar putih di kiri-kanan hilang!
    }
}

#Preview {
    ContentView()
}

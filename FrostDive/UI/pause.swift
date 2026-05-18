//
//  pause.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SwiftUI

struct pause: View {
    @ObservedObject var gameState: gameState
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("PAUSE")
                    .font(.custom("milner", size: 55, relativeTo: .title))
                    .foregroundStyle(Color(hex: "#D8EDF5"))
                
                Button(action: {
                    gameState.isPaused = false
                }) {
                    Image("continuePause")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                }
                
                Button(action: {
                    gameState.isPaused = false
                    gameState.shouldReturnHome = true
                }) {
                    Image("homePause")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                }
            }
//            .offset(x: 35, y: 25)
        }
    }
}

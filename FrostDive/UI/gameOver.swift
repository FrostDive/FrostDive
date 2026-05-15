//
//  gameOver.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 13/05/26.
//

import SwiftUI

struct gameOver: View {
    @ObservedObject var gameState: gameState
    @ObservedObject var playerStats: playerStats
    
    var body: some View {
        ZStack {
            Image("popUpGameOver")
                .resizable()
                .scaledToFit()
                .frame(width: 550)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                Text("Game Over")
                    .font(.custom("milner", size: 30, relativeTo: .title))
                    .foregroundStyle(Color(hex: "#005085"))
                
                Text("Distances")
                    .font(.title)
                    .foregroundColor(Color(hex: "#75B5D1"))
                Text("\(Int(gameState.distance))m")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color(hex: "#005085"))
                
                HStack{
                    Text("Total Trash: ")
                        .font(.title)
                        .foregroundColor(Color(hex: "#75B5D1"))
                    Text("\(gameState.trash)")
                        .font(.title)
                        .foregroundColor(Color(hex: "#005085"))
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        gameState.isGameOver = false
                        gameState.currentScreen = .home
                    }) {
                        Image("homeGameOver")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 50)
                    }
                    
                    Button(action: {
                        gameState.isGameOver = false
                        gameState.trash = 0
                        gameState.distance = 0
                    }) {
                        Image("retryGameOver")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 50)
                    }
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

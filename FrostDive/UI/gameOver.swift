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
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            Image("popUpGameOver")
                .resizable()
                .scaledToFit()
                .frame(width: 600)
                .edgesIgnoringSafeArea(.all)
                .padding(.top, 18)
            
            VStack {
                Text("GAME OVER")
                    .font(.custom("milner", size: 50, relativeTo: .title))
                    .foregroundStyle(Color(hex: "#005085"))
                
                Text("Distances")
                    .font(.custom("milner", size: 30, relativeTo: .title))
                    .foregroundColor(Color(hex: "#75B5D1"))
                Text("\(Int(gameState.distance))m")
                    .font(.custom("milner", size: 40, relativeTo: .title))
                    .bold()
                    .foregroundColor(Color(hex: "#005085"))
                
                HStack{
                    Text("Total Trash:")
                        .font(.custom("milner", size: 30, relativeTo: .title))
                        .foregroundColor(Color(hex: "#75B5D1"))
                    Text("\(gameState.trash)")
                        .font(.custom("milner", size: 30, relativeTo: .title))
                        .foregroundColor(Color(hex: "#005085"))
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        gameState.isGameOver = false
                        gameState.shouldReturnHome = true
                    }) {
                        Image("homeGameOver")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180)
                    }
                    
                    Button(action: {
                        gameState.isGameOver = false
                        gameState.trash = 0
                        gameState.distance = 0
                    }) {
                        Image("retryGameOver")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.top, 10)
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

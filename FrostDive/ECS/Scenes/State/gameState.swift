//
//  gameState.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 13/05/26.
//

import SwiftUI
import Combine

class gameState: ObservableObject {
    @Published var isPaused: Bool = false
    @Published var isGameOver: Bool = false
    
    @Published var trash: Int = 0
    @Published var distance: CGFloat = 0
    @Published var isDarkScene: Bool = false
    @Published var isMagnetic: Bool = false
    @Published var currentScreen: AppScreen = .home
}

enum AppScreen {
    case home, shop, game
}

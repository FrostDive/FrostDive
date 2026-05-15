//
//  playerStats.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SwiftUI
import Combine

class playerStats: ObservableObject {
    @AppStorage("highScore") var highScore: Int = 0
    @AppStorage("trash") var trash: Int = 0
    @AppStorage("equippedSub") var equippedSub: String = "submarine1"
    @AppStorage("unlockedSubs") var unlockedSubsData: Data = Data()
    
    var unlockedSubs: [String] {
        get {
            if let decoded = try? JSONDecoder().decode([String].self, from: unlockedSubsData) { return decoded }
            return ["submarine1"]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) { unlockedSubsData = encoded }
        }
    }
}

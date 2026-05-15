//
//  soundComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit
import UIKit

class soundComponent: GKComponent {
    static let shared = soundComponent()
    func obstacleHaptic() {

        DispatchQueue.main.async {

            let generator = UIImpactFeedbackGenerator(style: .heavy)

            generator.prepare()
            generator.impactOccurred(intensity: 1.0)
        }
    }
}

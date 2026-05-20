//
//  floatingComponent.swift
//  FrostDive
//

import GameplayKit

class animationComponent: GKComponent {
    let animationDistance: CGFloat
    let animationSpeed: CGFloat // Seberapa cepat gelombangnya (mirip durasi)
    
    var timePassed: TimeInterval = 0
    var startY: CGFloat = 0
    var isInitialized: Bool = false
    
    init(distance: CGFloat, speed: CGFloat = 2.0) {
        self.animationDistance = distance
        self.animationSpeed = speed
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

//
//  movementComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit

class movementComponent: GKComponent {
    var speed: CGFloat
    
    init(speed: CGFloat) {
        self.speed = speed
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

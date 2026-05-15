//
//  thrustComponent.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 15/05/26.
//

import GameplayKit

class thrustComponent: GKComponent {
    var isThrusting: Bool = false
    var currentThrust: CGFloat
    let maxUpwardVelocity: CGFloat
    
    init(thrust: CGFloat = 15.0, maxVelocity: CGFloat = 300.0) {
        self.currentThrust = thrust
        self.maxUpwardVelocity = maxVelocity
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

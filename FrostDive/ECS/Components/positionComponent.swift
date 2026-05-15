//
//  positionComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit

class positionComponent: GKComponent {
    var position: CGPoint
    
    init(position: CGPoint) {
        self.position = position
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



//
//  fish.swift
//  FrostDive
//
//  Created by Steffany Florence on 21/05/26.
//

import GameplayKit
import SpriteKit

class fishEntity: GKEntity {
    init(imageName: String, startPosition: CGPoint, speed: CGFloat) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        let sprite = spriteComponent(texture: texture, size: CGSize(width: 150, height: 50))
        
        // Place fish behind the submarine (0) but in front of the background (-10)
        sprite.node.zPosition = -5
        sprite.node.name = "ambient_fish"
        
        addComponent(sprite)
        addComponent(positionComponent(position: startPosition))
        addComponent(movementComponent(speed: speed))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

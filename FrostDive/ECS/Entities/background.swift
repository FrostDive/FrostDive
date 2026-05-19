//
//  background.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 13/05/26.
//

import GameplayKit
import SpriteKit

class backgroundEntity: GKEntity {
    let index: Int // Menyimpan urutan background (0-14)
    
    init(imageName: String, size: CGSize, startPosition: CGPoint, speed: CGFloat, index: Int) {
        self.index = index
        super.init()
        
        addComponent(positionComponent(position: startPosition))
        addComponent(spriteComponent(texture: SKTexture(imageNamed: imageName), size: size))
        addComponent(movementComponent(speed: speed))
        
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

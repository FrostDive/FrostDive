//
//  submarine.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit
import GameplayKit

class submarineEntity: GKEntity {
    let baseName: String
    init(imageName: String, size: CGSize, startPosition: CGPoint) {
        self.baseName = imageName
        super.init()
        
        let texture: SKTexture = .init(imageNamed: imageName)
        
        // 1. Data Posisi & Visual
        addComponent(positionComponent(position: startPosition))
        addComponent(spriteComponent(texture: texture, size: size))
        addComponent(thrustComponent(thrust: 15.0, maxVelocity: 300.0))
        
        // 3. Konfigurasi Fisika
        if let spriteNode = component(ofType: spriteComponent.self)?.node {
            spriteNode.physicsBody = SKPhysicsBody(texture: texture, size: size)
            spriteNode.physicsBody?.isDynamic = true
            spriteNode.physicsBody?.affectedByGravity = true
            spriteNode.physicsBody?.allowsRotation = false
            spriteNode.physicsBody?.categoryBitMask = physicsCategory.submarine
            spriteNode.physicsBody?.contactTestBitMask = physicsCategory.trash | physicsCategory.obstacle
            spriteNode.physicsBody?.collisionBitMask = physicsCategory.edge
        }
    }
    
    func setMagnetSubmarineTexture(isActive: Bool) {
        let textureName = isActive ? "\(baseName)_magnet" : baseName
        let newTexture = SKTexture(imageNamed: textureName)
        
        self.component(ofType: spriteComponent.self)?.updateTexture(newTexture)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

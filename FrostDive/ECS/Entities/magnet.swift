//
//  magnet.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit
import GameplayKit

class magnetEntity: GKEntity {
    init(imageName: String, size: CGSize, startPosition: CGPoint, speed: CGFloat) {
        super.init()
        
        let texture: SKTexture = .init(imageNamed: imageName)
        
        // 1. Data Posisi & Visual
        addComponent(positionComponent(position: startPosition))
        addComponent(spriteComponent(texture: texture, size: size))
        
        // 2. Data Gerak (Ini yang membuat dia bisa bergerak)
        addComponent(movementComponent(speed: speed))
        // Jarak 15, kecepatan gelombang standar (2.0)
        addComponent(animationComponent(distance: 140.0, speed: 2.0))
        
        // 3. Konfigurasi Fisika
        if let spriteNode = component(ofType: spriteComponent.self)?.node {
            spriteNode.name = "magnet"
            spriteNode.physicsBody = SKPhysicsBody(texture: texture, size: size)
            spriteNode.physicsBody?.isDynamic = false // Agar tidak jatuh kena gravitasi
            spriteNode.physicsBody?.categoryBitMask = physicsCategory.power
            spriteNode.physicsBody?.contactTestBitMask = physicsCategory.submarine
            spriteNode.physicsBody?.collisionBitMask = physicsCategory.none
        }
        
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

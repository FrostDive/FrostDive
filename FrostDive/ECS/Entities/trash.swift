//
//  trash.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit
import SpriteKit

class trashEntity: GKEntity {
    init(
        imageName: String,
        size: CGSize,
        startPosition: CGPoint,
        speed: CGFloat
    ) {
        super.init()

        let texture: SKTexture = .init(imageNamed: imageName)

        // 1. Data Posisi & Visual
        addComponent(positionComponent(position: startPosition))
        addComponent(spriteComponent(texture: texture, size: size))

        // 2. Data Gerak (Ini yang membuat dia bisa bergerak)
        addComponent(movementComponent(speed: speed))
        // Jarak 15, kecepatan gelombang standar (2.0)
        addComponent(animationComponent(distance: 15.0, speed: 2.0))
        
        
        // 3. Konfigurasi Fisika
        if let spriteNode = component(ofType: spriteComponent.self)?.node {
            spriteNode.name = "trash"
            
            let radius = min(size.width, size.height) / 1.5
            spriteNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            spriteNode.physicsBody?.isDynamic = false  // Agar tidak jatuh kena gravitasi
            spriteNode.physicsBody?.categoryBitMask = physicsCategory.trash
            spriteNode.physicsBody?.contactTestBitMask = physicsCategory.submarine
            spriteNode.physicsBody?.collisionBitMask = physicsCategory.none

            animationComponent.addBubbleEffect(
                to: spriteNode
            )
        }

    }
    required init?(coder: NSCoder) { fatalError() }

}

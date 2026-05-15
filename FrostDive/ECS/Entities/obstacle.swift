//
//  obstacle.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

<<<<<<< HEAD
import GameplayKit
import SpriteKit

class obstacleEntity: GKEntity {
    init(imageName: String, size: CGSize, startPosition: CGPoint, speed: CGFloat) {
        super.init()
        
        
        let texture: SKTexture = .init(imageNamed: imageName)
        
        // 1. Data Posisi & Visual
        addComponent(positionComponent(position: startPosition))
        addComponent(spriteComponent(texture: texture, size: size))
        
        // 2. Data Gerak (Ini yang membuat dia bisa bergerak)
        addComponent(movementComponent(speed: speed))
        
        // 3. Konfigurasi Fisika
        if let spriteNode = component(ofType: spriteComponent.self)?.node {
            spriteNode.name = "trash"
            spriteNode.physicsBody = SKPhysicsBody(texture: texture, size: size)
            spriteNode.physicsBody?.isDynamic = false // Agar tidak jatuh kena gravitasi
            spriteNode.physicsBody?.categoryBitMask = physicsCategory.obstacle
            spriteNode.physicsBody?.contactTestBitMask = physicsCategory.submarine
            spriteNode.physicsBody?.collisionBitMask = physicsCategory.none
        }
    }
    required init?(coder: NSCoder) { fatalError() }
=======
import SpriteKit
import GameplayKit

class obstacleEntity: GKEntity {
    init(imageName: String, size: CGSize) {
        super.init()
        
        let texture: SKTexture = .init(imageNamed: imageName) // nanti cara pakenya gini
        let spriteComponent = spriteComponent(texture: texture, size: size)
        addComponent(spriteComponent)
        
        let node = spriteComponent.node
        node.physicsBody = SKPhysicsBody(texture: texture, size: size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = physicsCategory.obstacle
        node.physicsBody?.contactTestBitMask = physicsCategory.submarine
        node.physicsBody?.collisionBitMask = physicsCategory.none
        
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
>>>>>>> dev
}

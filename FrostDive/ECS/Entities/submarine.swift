//
//  submarine.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit
import GameplayKit

class submarineEntity: GKEntity {
<<<<<<< HEAD
    init(imageName: String, size: CGSize, startPosition: CGPoint) {
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
=======
    init(imageName: String, size: CGSize) {
        super.init()
        
        let texture: SKTexture = .init(imageNamed: imageName)
        // nanti cara pakenya gini let submarine = submarineEntity(imageName: "submarine", size: CGSize(width: 120, height: 82))
        let spriteComponent = spriteComponent(texture: texture, size: size)
        addComponent(spriteComponent)
        
        let node = spriteComponent.node
        node.physicsBody = SKPhysicsBody(texture: texture, size: size)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = physicsCategory.submarine
        node.physicsBody?.contactTestBitMask = physicsCategory.trash | physicsCategory.obstacle
        node.physicsBody?.collisionBitMask = physicsCategory.none
>>>>>>> dev
        
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
<<<<<<< HEAD




=======
>>>>>>> dev

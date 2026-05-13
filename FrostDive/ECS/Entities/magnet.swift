//
//  magnet.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit
import GameplayKit

class magnetEntity: GKEntity {
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
}

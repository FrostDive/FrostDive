//
//  submarine.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit
import GameplayKit

class submarineEntity: GKEntity {
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
        
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

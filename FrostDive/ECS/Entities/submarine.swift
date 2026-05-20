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
    init(imageName: String, startPosition: CGPoint) {
        self.baseName = imageName
        super.init()
        
        let texture: SKTexture = .init(imageNamed: imageName)
        let size = texture.size()
        
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
            let newSize = newTexture.size()
            
            if let spriteComp = self.component(ofType: spriteComponent.self) {
                // 1. Update Tekstur Visual
                spriteComp.updateTexture(newTexture)
                
                // 2. Update Ukuran Visual
                spriteComp.node.size = newSize
                
                // 3. Update Hitbox Fisika (PENTING!)
                // Buat ulang physicsBody agar menyesuaikan dengan lekuk dan ukuran baru
                spriteComp.node.physicsBody = SKPhysicsBody(texture: newTexture, size: newSize)
                
                // 4. Konfigurasi ulang sifat fisikanya (karena body yang lama sudah ditimpa)
                spriteComp.node.physicsBody?.isDynamic = true
                spriteComp.node.physicsBody?.affectedByGravity = true
                spriteComp.node.physicsBody?.allowsRotation = false
                spriteComp.node.physicsBody?.categoryBitMask = physicsCategory.submarine
                spriteComp.node.physicsBody?.contactTestBitMask = physicsCategory.trash | physicsCategory.obstacle
                spriteComp.node.physicsBody?.collisionBitMask = physicsCategory.edge
            }
        }
    
    required init?(coder: NSCoder) { fatalError() }
}

//
//  submarine.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit
import GameplayKit

enum submarineType {
    case normal(Int)
    
    var imageName: String {
        switch self {
        case .normal(let number):
            return "submarine\(number)_game"
        }
    }
    
    var magnetImageName: String {
        switch self {
        case .normal(let number):
            return "submarine\(number)_game_magnet"
        }
    }
    
    var size: CGSize {
        switch self {
        case .normal(1):
            return CGSize(width: 124, height: 85)

        case .normal(2):
            return CGSize(width: 115, height: 90)

        case .normal(3):
            return CGSize(width: 126, height: 65)

        case .normal(4):
            return CGSize(width: 107, height: 87)

        case .normal(5):
            return CGSize(width: 84, height: 85)

        case .normal(6):
            return CGSize(width: 106, height: 84)

        default:
            return CGSize(width: 124, height: 85)
        }
    }
    
    var magnetSize: CGSize {
        switch self {
        case .normal(1):
            return CGSize(width: 142, height: 95)

        case .normal(2):
            return CGSize(width: 121, height: 104)

        case .normal(3):
            return CGSize(width: 163, height: 80)

        case .normal(4):
            return CGSize(width: 138, height: 86)

        case .normal(5):
            return CGSize(width: 116, height: 89)

        case .normal(6):
            return CGSize(width: 140, height: 91)

        default:
            return CGSize(width: 142, height: 95)
        }
    }
}

class submarineEntity: GKEntity {
    let submarine: submarineType
    init(type: submarineType, startPosition: CGPoint) {
        self.submarine = type
        super.init()
        
        let texture: SKTexture = .init(imageNamed: type.imageName)
        
        let size = type.size
        
        
        
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
            let textureName = isActive ? submarine.magnetImageName : submarine.imageName
            let newTexture = SKTexture(imageNamed: textureName)
        let newSize = isActive ? submarine.magnetSize : submarine.size
        // Contoh jika ingin memperbesar ukuran magnet sebesar 1.2x dari ukuran aslinya

            
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

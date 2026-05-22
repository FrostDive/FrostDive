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

extension submarineType {
    func physicsBody(isMagnet: Bool) -> SKPhysicsBody {
        let currentSize = isMagnet ? self.magnetSize : self.size
        var bodies = [SKPhysicsBody]()
        
        switch self {
        case .normal(1):
            // 1. Settings for the two LARGE circles
            let mainRadius = currentSize.height / 3.5
            let horizontalOffset = currentSize.width / 4
            
            // ADJUST THIS: Negative moves them down (e.g., height / 10)
            let mainBodyVerticalOffset = -currentSize.height / 8
            
            // Left & Right Circle
            bodies.append(SKPhysicsBody(circleOfRadius: mainRadius, center: CGPoint(x: -horizontalOffset, y: mainBodyVerticalOffset)))
            bodies.append(SKPhysicsBody(circleOfRadius: mainRadius, center: CGPoint(x: horizontalOffset, y: mainBodyVerticalOffset)))
            
            // 2. Settings for the SMALL TOP circle
            let topRadius = currentSize.height / 6
            
            // Keep this Positive to keep it at the top
            let topVerticalOffset = currentSize.height / 3.5
            
            bodies.append(SKPhysicsBody(circleOfRadius: topRadius, center: CGPoint(x: 5, y: topVerticalOffset)))
            
        case .normal(2):
            // Example: One large body circle and one small tail circle
            bodies.append(SKPhysicsBody(circleOfRadius: currentSize.height / 2.2, center: CGPoint(x: 10, y: 0)))
            bodies.append(SKPhysicsBody(circleOfRadius: currentSize.height / 4, center: CGPoint(x: -40, y: -10)))
            
        case .normal(3):
            // Two horizontally aligned circles
            let radius = currentSize.height / 2
            let offset = currentSize.width / 4
            bodies.append(SKPhysicsBody(circleOfRadius: radius, center: CGPoint(x: -offset, y: 0)))
            bodies.append(SKPhysicsBody(circleOfRadius: radius, center: CGPoint(x: offset, y: 0)))

        case .normal(4):
            // One big circle in the center
            let radius = min(currentSize.width, currentSize.height) / 2
            bodies.append(SKPhysicsBody(circleOfRadius: radius))

        case .normal(5):
            // One big circle in the center
            let radius = min(currentSize.width, currentSize.height) / 2
            bodies.append(SKPhysicsBody(circleOfRadius: radius))
            
        case .normal(6):
            // One big circle in the center
            let radius = min(currentSize.width, currentSize.height) / 2
            bodies.append(SKPhysicsBody(circleOfRadius: radius))
            
            let topRadius = currentSize.height / 6
            bodies.append(SKPhysicsBody(circleOfRadius: topRadius, center: CGPoint(x: 40, y: -25)))
            
        default:
            // Fallback: Default single circle
            bodies.append(SKPhysicsBody(circleOfRadius: min(currentSize.width, currentSize.height) / 2))
        }
        
        // Combine all bodies into one
        let compoundBody = SKPhysicsBody(bodies: bodies)
        return compoundBody
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
        
        setupPhysics(isMagnet: false)
    }
    
    func setMagnetSubmarineTexture(isActive: Bool) {
        if let spriteComp = self.component(ofType: spriteComponent.self) {
            let textureName = isActive ? submarine.magnetImageName : submarine.imageName
            let newSize = isActive ? submarine.magnetSize : submarine.size
            
            spriteComp.updateTexture(SKTexture(imageNamed: textureName))
            spriteComp.node.size = newSize
            
            // Re-apply the custom circular physics
            setupPhysics(isMagnet: isActive)
        }
    }
    
    private func setupPhysics(isMagnet: Bool) {
        guard let spriteNode = component(ofType: spriteComponent.self)?.node else { return }
        
        // Get the custom compound body from our enum logic
        let body = submarine.physicsBody(isMagnet: isMagnet)
        
        // Apply properties
        body.isDynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        body.categoryBitMask = physicsCategory.submarine
        body.contactTestBitMask = physicsCategory.trash | physicsCategory.obstacle
        body.collisionBitMask = physicsCategory.edge
        
        spriteNode.physicsBody = body
    }

    
    required init?(coder: NSCoder) { fatalError() }
}

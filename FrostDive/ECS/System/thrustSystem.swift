//
//  thrustSystem.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 15/05/26.
//

import GameplayKit
import SpriteKit

class thrustSystem: GKComponentSystem<thrustComponent> {
    
    override init() {
        super.init(componentClass: thrustComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        for component in components {
            // Kita butuh node visualnya untuk mengakses physicsBody
            guard let entity = component.entity,
                  let spriteComp = entity.component(ofType: spriteComponent.self),
                  let physicsBody = spriteComp.node.physicsBody else { continue }
            
            if component.isThrusting {
                // 1. Terapkan dorongan (applyContinousThrust)
                physicsBody.applyImpulse(CGVector(dx: 0, dy: component.currentThrust))
                
                // 2. Batasi kecepatan maksimal
                if physicsBody.velocity.dy > component.maxUpwardVelocity {
                    physicsBody.velocity.dy = component.maxUpwardVelocity
                }
            } else {
                // (cutEngine) Kembalikan nilai thrust ke awal jika dibutuhkan
                component.currentThrust = 15.0
            }
        }
    }
}

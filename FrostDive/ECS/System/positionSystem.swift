//
//  positionSystem.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 13/05/26.
//

import GameplayKit

class positionSystem: GKComponentSystem<positionComponent> {
    override func update(deltaTime seconds: TimeInterval) {
        for component in components {
            guard let entity = component.entity,
                  let spriteNode = entity.component(ofType: spriteComponent.self)?.node else { continue }
            
            spriteNode.position = component.position
        }
    }
}

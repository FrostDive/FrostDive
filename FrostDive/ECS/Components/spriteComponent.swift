//
//  spriteComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit
import GameplayKit

class spriteComponent: GKComponent {
    
    let node: SKSpriteNode
    
    init (texture: SKTexture, size: CGSize) {
        self.node = SKSpriteNode(texture: texture, color: .clear, size: size)
        super.init()
    }
    
    func updateTexture(_ texture:SKTexture)  {
        node.texture = texture
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

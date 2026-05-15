//
//  spriteComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit
import SpriteKit

class spriteComponent: GKComponent {

    let node: SKSpriteNode

    let normalTexture = SKTexture(imageNamed: "submarine1")
    let magnetTexture = SKTexture(imageNamed: "submarineMagnet1")

    init(texture: SKTexture, size: CGSize) {
        self.node = SKSpriteNode(texture: texture, color: .clear, size: size)
        super.init()
    }

    func updateTexture(_ texture: SKTexture) {
        node.texture = texture
    }

    func setNormal() {
        node.texture = normalTexture
    }

    func setMagnet() {
        node.texture = magnetTexture
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

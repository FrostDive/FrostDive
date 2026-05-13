//
//  gameScene.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit
import GameplayKit

class gameScene: SKScene, SKPhysicsContactDelegate{
    
    var entities = [GKEntity]()
    
    func spawnSubmarine(){
        let submarine = submarineEntity(imageName: "submarine", size: CGSize(width: 120, height: 82))
        
        if let spriteComponent = submarine.component(ofType: spriteComponent.self) {
            let node = spriteComponent.node
            node.position = CGPoint(x: size.width * 0.2, y: size.height / 2)
            addChild(node)
        }
        self.entities.append(submarine)
    }
    
    override func didMove(to view: SKView) {
        spawnSubmarine()
    }
}

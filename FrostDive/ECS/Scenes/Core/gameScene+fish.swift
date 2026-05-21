//
//  gameScene+fish.swift
//  FrostDive
//
//  Created by Steffany Florence on 21/05/26.
//

import GameplayKit
import SpriteKit

extension gameScene {
    func startFishSpawning() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnFish()
        }

        let waitAction = SKAction.wait(forDuration: TimeInterval.random(in: 3.0...6.0))
        let sequence = SKAction.sequence([spawnAction, waitAction])
        
        run(SKAction.repeatForever(sequence), withKey: "fish_spawn")
    }
    
    private func spawnFish() {
        let fishImages = ["fishSmall", "fishBig"]
        let randomImage = fishImages.randomElement() ?? "fishSmall"
        
        let fishSpeed: CGFloat = (randomImage == "fishBig") ? 6.0 : 9.0
        
        let startX = size.width + 100
        let randomY = CGFloat.random(in: 100...(size.height - 100))
        let startPos = CGPoint(x: startX, y: randomY)
        
        let fish = fishEntity(imageName: randomImage, startPosition: startPos, speed: fishSpeed)
        
        if let s = fish.component(ofType: spriteComponent.self) {
            addChild(s.node)
        }
        if let p = fish.component(ofType: positionComponent.self) {
            posSystem.addComponent(p)
        }
        if let m = fish.component(ofType: movementComponent.self) {
            moveSystem.addComponent(m)
        }
        
        entities.append(fish)
    }
}

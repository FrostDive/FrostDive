//
//  flashlightComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit
import SpriteKit

class flashlightComponent: GKComponent {
    
    var containerNode: SKNode!
    private weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
        super.init()
        setupFlashlight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFlashlight() {
        containerNode = SKNode()
        containerNode.zPosition = 50
        containerNode.alpha = 0 
        
        let numberOfDarkLayers = 8
        
        let maxBeamLength: CGFloat = 550
        let maxEndSpread: CGFloat = 280
        
        let minBeamLength: CGFloat = 350
        let minEndSpread: CGFloat = 120
        
        let startOffset: CGFloat = 50
        let alphaPerLayer: CGFloat = 0.25
        
        for i in 0..<numberOfDarkLayers {
            let progress = CGFloat(i) / CGFloat(numberOfDarkLayers - 1)
            
            let currentBeamLength = maxBeamLength - ((maxBeamLength - minBeamLength) * progress)
            let currentEndSpread = maxEndSpread - ((maxEndSpread - minEndSpread) * progress)
            
            let path = CGMutablePath()
            path.addRect(CGRect(x: -3000, y: -3000, width: 6000, height: 6000))
            
            let bulgeStartX = startOffset + (currentBeamLength * 0.6)
            
            path.move(to: CGPoint(x: startOffset, y: 0))
            
            path.addCurve(to: CGPoint(x: currentBeamLength, y: 0),
                          control1: CGPoint(x: bulgeStartX, y: -currentEndSpread),
                          control2: CGPoint(x: currentBeamLength, y: -currentEndSpread))
            
            path.addCurve(to: CGPoint(x: startOffset, y: 0),
                          control1: CGPoint(x: currentBeamLength, y: currentEndSpread),
                          control2: CGPoint(x: bulgeStartX, y: currentEndSpread))
            
            path.closeSubpath()
            
            let layerNode = SKShapeNode(path: path)
            layerNode.fillColor = UIColor.black.withAlphaComponent(alphaPerLayer)
            layerNode.strokeColor = .clear
            
            containerNode.addChild(layerNode)
        }
        
        let numberOfGlowLayers = 3
        
        for i in 0..<numberOfGlowLayers {
            let progress = CGFloat(i) / CGFloat(numberOfGlowLayers)
            
            let glowBeamLength = minBeamLength - 10 - (40 * progress)
            let glowEndSpread = minEndSpread - 10 - (30 * progress)
            
            let beamPath = CGMutablePath()
            
            let bulgeStartX = startOffset + (glowBeamLength * 0.6)
            
            beamPath.move(to: CGPoint(x: startOffset, y: 0))
            
            beamPath.addCurve(to: CGPoint(x: glowBeamLength, y: 0),
                              control1: CGPoint(x: bulgeStartX, y: glowEndSpread),
                              control2: CGPoint(x: glowBeamLength, y: glowEndSpread))
            
            beamPath.addCurve(to: CGPoint(x: startOffset, y: 0),
                              control1: CGPoint(x: glowBeamLength, y: -glowEndSpread),
                              control2: CGPoint(x: bulgeStartX, y: -glowEndSpread))
            
            beamPath.closeSubpath()
            
            let beamNode = SKShapeNode(path: beamPath)
            beamNode.fillColor = UIColor.white.withAlphaComponent(0.06)
            beamNode.strokeColor = .clear
            beamNode.blendMode = .add
            
            containerNode.addChild(beamNode)
        }
    }
    
    func startLightingCycle() {
        let waitDaylight = SKAction.wait(forDuration: 20.0)
        let fadeToDark = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        let waitDarkness = SKAction.wait(forDuration: 10.0)
        let fadeToLight = SKAction.fadeAlpha(to: 0.0, duration: 1.5)
        
        let cycle = SKAction.sequence([waitDaylight, fadeToDark, waitDarkness, fadeToLight])
        containerNode.run(SKAction.repeatForever(cycle), withKey: "lighting_cycle")
    }
    
    override func didAddToEntity() {
        guard let spriteComp = entity?.component(ofType: spriteComponent.self) else { return }
        
        scene?.addChild(containerNode)
        
        let followConstraint = SKConstraint.distance(SKRange(constantValue: 0), to: spriteComp.node)
        containerNode.constraints = [followConstraint]
    }
    
    override func willRemoveFromEntity() {
        containerNode.removeFromParent()
    }
}

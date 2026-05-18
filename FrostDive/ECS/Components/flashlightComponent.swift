//
//  flashlightComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit
import SpriteKit

class flashlightComponent: GKComponent {
    
    var darknessNode: SKShapeNode!
    var beamNode: SKShapeNode!
    
    override init() {
        super.init()
        setupFlashlight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFlashlight() {
        let path = CGMutablePath()
        
        // 1. Massive rectangle (drawn clockwise by default)
        path.addRect(CGRect(x: -3000, y: -3000, width: 6000, height: 6000))
        
        // 2. Define the new flashlight dimensions
        let beamLength: CGFloat = 450   // Shorter length (roughly half the screen)
        let endSpread: CGFloat = 200    // How wide it gets at the far right end
        let startSpread: CGFloat = 25   // The width at the submarine (flattens the pointy tip)
        let startOffset: CGFloat = 50   // Offset slightly in front of the submarine
        
        // 3. Draw the trapezoid cutout COUNTER-CLOCKWISE to subtract it from the rectangle
        path.move(to: CGPoint(x: startOffset, y: startSpread))       // Top-Left (at submarine)
        path.addLine(to: CGPoint(x: startOffset, y: -startSpread))   // Bottom-Left (at submarine)
        path.addLine(to: CGPoint(x: beamLength, y: -endSpread))      // Bottom-Right (far end)
        path.addLine(to: CGPoint(x: beamLength, y: endSpread))       // Top-Right (far end)
        path.closeSubpath()                                          // Back to start
        
        // 4. Setup the Darkness Node
        darknessNode = SKShapeNode(path: path)
        darknessNode.fillColor = UIColor.black.withAlphaComponent(0.95) // Very dark!
        darknessNode.strokeColor = .clear
        darknessNode.zPosition = 50
        darknessNode.alpha = 0 // IMPORTANT: Start invisible so the game begins in daylight
        
        // 5. Setup the glowing Light Beam Node (drawn clockwise normally)
        let beamPath = CGMutablePath()
        beamPath.move(to: CGPoint(x: startOffset, y: startSpread))
        beamPath.addLine(to: CGPoint(x: beamLength, y: endSpread))
        beamPath.addLine(to: CGPoint(x: beamLength, y: -endSpread))
        beamPath.addLine(to: CGPoint(x: startOffset, y: -startSpread))
        beamPath.closeSubpath()
        
        beamNode = SKShapeNode(path: beamPath)
        beamNode.fillColor = UIColor.white.withAlphaComponent(0.15)
        beamNode.strokeColor = .clear
        beamNode.blendMode = .add
        
        // Attach the beam to the darkness overlay
        darknessNode.addChild(beamNode)
    }
    
    // 6. Add the timing logic
    func startLightingCycle() {
        // Create the sequence: Wait -> Fade to Dark -> Wait -> Fade to Light
        // Note: I added a 1.5-second fade duration so it transitions smoothly instead of flashing instantly
        let waitDaylight = SKAction.wait(forDuration: 20.0)
        let fadeToDark = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        let waitDarkness = SKAction.wait(forDuration: 10.0)
        let fadeToLight = SKAction.fadeAlpha(to: 0.0, duration: 1.5)
        
        let cycle = SKAction.sequence([waitDaylight, fadeToDark, waitDarkness, fadeToLight])
        
        // Run it forever
        darknessNode.run(SKAction.repeatForever(cycle), withKey: "lighting_cycle")
    }
    
    override func didAddToEntity() {
        if let spriteComp = entity?.component(ofType: spriteComponent.self) {
            spriteComp.node.addChild(darknessNode)
        }
    }
    
    override func willRemoveFromEntity() {
        darknessNode.removeFromParent()
    }
}

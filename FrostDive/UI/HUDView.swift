//
//  HUDView.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit

class HUDView: SKNode {
    
    // MARK: - Properties
    private var distanceIcon: SKSpriteNode!
    private var trashIcon: SKSpriteNode!
    private var distanceLabel: SKLabelNode!
    private var trashLabel: SKLabelNode!
    private var pauseButton: SKSpriteNode!
    
    private var sceneSize: CGSize
    
    // Public state
    var distance: Int = 0 {
        didSet { distanceLabel.text = "\(distance)m" }
    }
    var trashCount: Int = 0 {
        didSet { trashLabel.text = "\(trashCount)" }
    }
    
    // MARK: - Init
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init()
        setupHUD()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupHUD() {
        zPosition = 100
        
        // --- Pause button (top left) ---
        pauseButton = SKSpriteNode(imageNamed: "pauseIcon")
        pauseButton.size = CGSize(width: 32, height: 32)
        pauseButton.position = CGPoint(x: 26, y: sceneSize.height - 22)
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 100
        addChild(pauseButton)
        
        // --- Distance (top center-right) ---
        distanceIcon = SKSpriteNode(imageNamed: "distanceIcon")
        distanceIcon.size = CGSize(width: 26, height: 26)
        distanceIcon.position = CGPoint(x: sceneSize.width / 2 + 10, y: sceneSize.height - 22)
        distanceIcon.zPosition = 100
        addChild(distanceIcon)
        
        distanceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        distanceLabel.text = "0m"
        distanceLabel.fontSize = 15
        distanceLabel.fontColor = .white
        distanceLabel.horizontalAlignmentMode = .left
        distanceLabel.verticalAlignmentMode = .center
        distanceLabel.position = CGPoint(x: sceneSize.width / 2 + 28, y: sceneSize.height - 22)
        distanceLabel.zPosition = 100
        addChild(distanceLabel)
        
        // --- Trash count (top right) ---
        trashIcon = SKSpriteNode(imageNamed: "trashIcon")
        trashIcon.size = CGSize(width: 26, height: 26)
        trashIcon.position = CGPoint(x: sceneSize.width - 46, y: sceneSize.height - 22)
        trashIcon.zPosition = 100
        addChild(trashIcon)
        
        trashLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        trashLabel.text = "0"
        trashLabel.fontSize = 15
        trashLabel.fontColor = .white
        trashLabel.horizontalAlignmentMode = .left
        trashLabel.verticalAlignmentMode = .center
        trashLabel.position = CGPoint(x: sceneSize.width - 28, y: sceneSize.height - 22)
        trashLabel.zPosition = 100
        addChild(trashLabel)
    }
    
    // MARK: - Animations
    func animateTrashPickup() {
        let pop = SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        trashIcon.run(pop)
        trashLabel.run(pop)
        
        // +1 floating label
        let plusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        plusLabel.text = "+1"
        plusLabel.fontSize = 18
        plusLabel.fontColor = SKColor(red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0)
        plusLabel.position = CGPoint(x: sceneSize.width - 46, y: sceneSize.height - 10)
        plusLabel.zPosition = 101
        addChild(plusLabel)
        
        let floatUp = SKAction.moveBy(x: 0, y: 30, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let group = SKAction.group([floatUp, fadeOut])
        plusLabel.run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }
    
    func updateDistance(_ meters: Int) {
        distance = meters
    }
    
    func incrementTrash() {
        trashCount += 1
        animateTrashPickup()
    }
}

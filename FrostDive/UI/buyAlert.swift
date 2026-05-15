//
//  buyAlert.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit


class BuyAlertNode: SKNode {
    
    // MARK: - Public
    let subIndex: Int
    
    // MARK: - Private
    private let price: Int
    private let canAfford: Bool
    private let sceneSize: CGSize
    
    // MARK: - Init
    init(subIndex: Int, price: Int, canAfford: Bool, sceneSize: CGSize) {
        self.subIndex = subIndex
        self.price = price
        self.canAfford = canAfford
        self.sceneSize = sceneSize
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        // Dim background overlay
        let dimOverlay = SKShapeNode(rectOf: sceneSize)
        dimOverlay.fillColor = SKColor(white: 0, alpha: 0.5)
        dimOverlay.strokeColor = .clear
        dimOverlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        dimOverlay.zPosition = 0
        addChild(dimOverlay)
        
        // Popup background
        let popup = SKSpriteNode(imageNamed: "popUpShop")
        popup.size = CGSize(width: 300, height: 220)
        popup.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        popup.zPosition = 1
        addChild(popup)
        
        if canAfford {
            buildAffordableContent(center: popup.position)
        } else {
            buildCannotAffordContent(center: popup.position)
        }
        
        // Entrance animation
        popup.setScale(0.1)
        popup.run(SKAction.spring(toScale: 1.0, duration: 0.4))
    }
    
    // MARK: - Affordable variant
    private func buildAffordableContent(center: CGPoint) {
        // Submarine preview
        let subSprite = SKSpriteNode(imageNamed: "submarine\(subIndex)")
        subSprite.size = CGSize(width: 120, height: 70)
        subSprite.position = CGPoint(x: center.x, y: center.y + 52)
        subSprite.zPosition = 2
        addChild(subSprite)
        
        // "BUY WITH X TRASH" label
        let buyLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        buyLabel.text = "BUY WITH \(price) TRASH"
        buyLabel.fontSize = 16
        buyLabel.fontColor = SKColor(red: 0.1, green: 0.35, blue: 0.65, alpha: 1.0)
        buyLabel.position = CGPoint(x: center.x, y: center.y + 2)
        buyLabel.zPosition = 2
        addChild(buyLabel)
        
        // CONFIRM button
        let confirmBtn = SKSpriteNode(imageNamed: "confirmShop")
        confirmBtn.size = CGSize(width: 130, height: 42)
        confirmBtn.position = CGPoint(x: center.x, y: center.y - 44)
        confirmBtn.zPosition = 2
        confirmBtn.name = "confirmBuy"
        addChild(confirmBtn)
        
        // CONFIRM label on top (in case asset doesn't have text)
        let confirmLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        confirmLabel.text = "CONFIRM"
        confirmLabel.fontSize = 18
        confirmLabel.fontColor = .white
        confirmLabel.position = CGPoint(x: center.x, y: center.y - 52)
        confirmLabel.zPosition = 3
        confirmLabel.name = "confirmBuy"
        addChild(confirmLabel)
    }
    
    // MARK: - Cannot afford variant
    private func buildCannotAffordContent(center: CGPoint) {
        // Submarine preview (smaller, grey-tinted)
        let subSprite = SKSpriteNode(imageNamed: "submarine\(subIndex)")
        subSprite.size = CGSize(width: 110, height: 65)
        subSprite.position = CGPoint(x: center.x, y: center.y + 50)
        subSprite.zPosition = 2
        subSprite.color = .gray
        subSprite.colorBlendFactor = 0.5
        addChild(subSprite)
        
        // "TRASH NOT ENOUGH" title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "TRASH NOT ENOUGH"
        titleLabel.fontSize = 18
        titleLabel.fontColor = SKColor(red: 0.1, green: 0.35, blue: 0.65, alpha: 1.0)
        titleLabel.position = CGPoint(x: center.x, y: center.y + 8)
        titleLabel.zPosition = 2
        addChild(titleLabel)
        
        // Needed amount hint
        let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        hintLabel.text = "You need \(price) trash"
        hintLabel.fontSize = 13
        hintLabel.fontColor = .darkGray
        hintLabel.position = CGPoint(x: center.x, y: center.y - 12)
        hintLabel.zPosition = 2
        addChild(hintLabel)
        
        // BACK button
        let backBtn = SKSpriteNode(imageNamed: "backShop")
        backBtn.size = CGSize(width: 100, height: 42)
        backBtn.position = CGPoint(x: center.x, y: center.y - 50)
        backBtn.zPosition = 2
        backBtn.name = "dismissPopup"
        addChild(backBtn)
        
        // BACK label
        let backLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        backLabel.text = "BACK"
        backLabel.fontSize = 18
        backLabel.fontColor = SKColor(red: 0.1, green: 0.35, blue: 0.65, alpha: 1.0)
        backLabel.position = CGPoint(x: center.x, y: center.y - 58)
        backLabel.zPosition = 3
        backLabel.name = "dismissPopup"
        addChild(backLabel)
    }
}

// MARK: - SKAction spring helper
private extension SKAction {
    static func spring(toScale scale: CGFloat, duration: TimeInterval) -> SKAction {
        let overshoot = SKAction.scale(to: scale * 1.15, duration: duration * 0.6)
        let settle = SKAction.scale(to: scale * 0.95, duration: duration * 0.2)
        let final = SKAction.scale(to: scale, duration: duration * 0.2)
        return SKAction.sequence([overshoot, settle, final])
    }
}

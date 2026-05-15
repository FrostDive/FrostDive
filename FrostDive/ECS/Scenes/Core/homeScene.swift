//
//  homeScene.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit

class homeScene: SKScene {
    
    // MARK: - properties
    private var background: SKSpriteNode!
    private var leftWhale: SKSpriteNode!
    private var rightWhale: SKSpriteNode!
    private var logoImage: SKSpriteNode!
    private var submarine: SKSpriteNode!
    private var startButton: SKSpriteNode!
    private var shopButton: SKSpriteNode!
    private var isTransitioningScene = false
    
    private var hudContainer: SKNode!
    private var distanceIcon: SKSpriteNode!
    private var trashIcon: SKSpriteNode!
    private var highScoreLabel: SKLabelNode!
    private var totalTrashLabel: SKLabelNode!
    
    // MARK: - lifecycle
    override func didMove(to view: SKView) {
        setupScene()
        setupBackground()
        setupWhales()
        setupHUD()
        setupTitle()
        setupSubmarine()
        setupButtons()
        startSubmarineAnimation()
    }
    
    // MARK: - setup
    private func setupScene() {
        backgroundColor = SKColor(red: 0.05, green: 0.15, blue: 0.30, alpha: 1.0)
    }
    
    private func setupBackground() {
        // layer paling belakang: background4base — water/sky base (full screen)
        let baseBackground = SKSpriteNode(imageNamed: "background4base")
        baseBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        baseBackground.size = self.size
        baseBackground.zPosition = -20
        addChild(baseBackground)

        background = SKSpriteNode(imageNamed: "backgroundHome")
        let bgAspect = background.size.height / max(background.size.width, 1)
        let bgWidth = size.width
        let bgHeight = bgWidth * bgAspect
        background.size = CGSize(width: bgWidth, height: bgHeight)
        background.position = CGPoint(x: size.width / 2, y: bgHeight / 2)
        background.zPosition = -10
        addChild(background)
    }

    private func setupWhales() {
        leftWhale = SKSpriteNode(imageNamed: "backgroundWhale")
        leftWhale.size = CGSize(width: 132, height: 43)
        leftWhale.position = CGPoint(x: size.width * 0.18, y: size.height * 0.50)
        leftWhale.zPosition = -5
        leftWhale.alpha = 0.85
        leftWhale.xScale = -abs(leftWhale.xScale)
        addChild(leftWhale)

        rightWhale = SKSpriteNode(imageNamed: "backgroundWhale")
        rightWhale.size = CGSize(width: 257, height: 84)
        rightWhale.position = CGPoint(x: size.width - 95, y: size.height * 0.62)
        rightWhale.zPosition = -5
        rightWhale.alpha = 0.85
        addChild(rightWhale)
    }
    
    private func setupHUD() {
        hudContainer = SKNode()
        hudContainer.zPosition = 10
        addChild(hudContainer)

        let topY = size.height - 32
        let labelFontSize: CGFloat = 16
        let iconLabelGap: CGFloat = 6
        let leftMargin: CGFloat = 60
        let rightMargin: CGFloat = 110
        let groupGap: CGFloat = 72

        let shopIconSize = CGSize(width: 22, height: 22)
        let distanceIconSize = CGSize(width: 28, height: 23)
        let trashIconSize = CGSize(width: 27.23, height: 23.61)

        shopButton = SKSpriteNode(imageNamed: "shopIcon")
        shopButton.size = shopIconSize
        shopButton.position = CGPoint(x: leftMargin, y: topY)
        shopButton.zPosition = 10
        shopButton.name = "shopButton"
        hudContainer.addChild(shopButton)

        let shopLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shopLabel.text = "Shop"
        shopLabel.fontSize = labelFontSize
        shopLabel.fontColor = .white
        shopLabel.horizontalAlignmentMode = .left
        shopLabel.verticalAlignmentMode = .center
        shopLabel.position = CGPoint(x: leftMargin + shopIconSize.width / 2 + iconLabelGap, y: topY)
        shopLabel.zPosition = 10
        shopLabel.name = "shopButton"
        hudContainer.addChild(shopLabel)

        let totalTrash = UserDefaults.standard.integer(forKey: "totalTrash")
        totalTrashLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        totalTrashLabel.text = "\(totalTrash)"
        totalTrashLabel.fontSize = labelFontSize
        totalTrashLabel.fontColor = .white
        totalTrashLabel.horizontalAlignmentMode = .right
        totalTrashLabel.verticalAlignmentMode = .center
        totalTrashLabel.position = CGPoint(x: size.width - rightMargin, y: topY)
        totalTrashLabel.zPosition = 10
        hudContainer.addChild(totalTrashLabel)

        let trashLabelWidth = totalTrashLabel.frame.width
        trashIcon = SKSpriteNode(imageNamed: "trashIcon")
        trashIcon.size = trashIconSize
        trashIcon.position = CGPoint(
            x: size.width - rightMargin - trashLabelWidth - iconLabelGap - trashIconSize.width / 2,
            y: topY
        )
        trashIcon.zPosition = 10
        hudContainer.addChild(trashIcon)

        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        highScoreLabel.text = "\(highScore)m"
        highScoreLabel.fontSize = labelFontSize
        highScoreLabel.fontColor = .white
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.verticalAlignmentMode = .center
        let distanceLabelRightX = trashIcon.position.x - trashIconSize.width / 2 - groupGap
        highScoreLabel.position = CGPoint(x: distanceLabelRightX, y: topY)
        highScoreLabel.zPosition = 10
        hudContainer.addChild(highScoreLabel)

        let distanceLabelWidth = highScoreLabel.frame.width
        distanceIcon = SKSpriteNode(imageNamed: "distanceIcon")
        distanceIcon.size = distanceIconSize
        distanceIcon.position = CGPoint(
            x: distanceLabelRightX - distanceLabelWidth - iconLabelGap - distanceIconSize.width / 2,
            y: topY
        )
        distanceIcon.zPosition = 10
        hudContainer.addChild(distanceIcon)
    }
    
    private func setupTitle() {
        logoImage = SKSpriteNode(imageNamed: "logo")
        let naturalAspect = logoImage.size.height / max(logoImage.size.width, 1)
        let logoWidth = size.width * 0.76
        logoImage.size = CGSize(width: logoWidth, height: logoWidth * naturalAspect)
        logoImage.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        logoImage.zPosition = 5
        addChild(logoImage)
    }
    
    private func setupSubmarine() {
        let equippedSub = UserDefaults.standard.integer(forKey: "equippedSubmarine")
        let subName: String
        if equippedSub <= 0 {
            subName = "submarine1"
        } else {
            subName = "submarine\(equippedSub)"
        }
        
        submarine = SKSpriteNode(imageNamed: subName)
        let subWidth: CGFloat = 160
        let subAspect = submarine.size.height / max(submarine.size.width, 1)
        submarine.size = CGSize(width: subWidth, height: subWidth * subAspect)
        submarine.position = CGPoint(x: size.width / 2, y: size.height * 0.40)
        submarine.zPosition = 5
        addChild(submarine)
    }
    
    private func setupButtons() {
        startButton = SKSpriteNode(imageNamed: "start")
        startButton.size = CGSize(width: 140, height: 50)
        startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.16)
        startButton.zPosition = 5
        startButton.name = "startButton"
        addChild(startButton)
    }
    
    private func startSubmarineAnimation() {
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 1.2)
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 1.2)
        moveUp.timingMode = .easeInEaseOut
        moveDown.timingMode = .easeInEaseOut
        let bobbing = SKAction.sequence([moveUp, moveDown])
        submarine.run(SKAction.repeatForever(bobbing))
    }
    
    // MARK: - touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNames = Set(self.nodes(at: location).compactMap { $0.name })

        if touchedNames.contains("startButton") {
            handleStartButton()
        } else if touchedNames.contains("shopButton") {
            handleShopButton()
        }
    }
    
    private func handleStartButton() {
        guard !isTransitioningScene else { return }
        isTransitioningScene = true

        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let transition = SKAction.run { [weak self] in
            self?.transitionToGame()
        }
        startButton.run(SKAction.sequence([scaleDown, scaleUp, transition]))
    }
    
    private func handleShopButton() {
        guard !isTransitioningScene else { return }
        isTransitioningScene = true

        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let transition = SKAction.run { [weak self] in
            self?.transitionToShop()
        }
        shopButton.run(SKAction.sequence([scaleDown, scaleUp, transition]))
    }
    
    private func transitionToGame() {
        let scene = gameScene(size: self.size)
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(scene, transition: transition)
    }
    
    private func transitionToShop() {
        let scene = shopScene(size: self.size)
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.4)
        self.view?.presentScene(scene, transition: transition)
    }
    
    // MARK: - data refresh
    func refreshHUD() {
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        let totalTrash = UserDefaults.standard.integer(forKey: "totalTrash")
        highScoreLabel.text = "\(highScore)m"
        totalTrashLabel.text = "\(totalTrash)"
    }
}

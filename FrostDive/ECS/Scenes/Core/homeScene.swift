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
    
    private var hudView: HUDView!

    var gameStateRef: gameState?
    
    // MARK: - lifecycle
    override func didMove(to view: SKView) {
        gameStateRef?.currentScreen = .home
        gameStateRef?.shouldReturnHome = false
        gameStateRef?.isPaused = false
        gameStateRef?.isGameOver = false

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
        let topY = size.height - 35
        let leftMargin: CGFloat = 92

        shopButton = SKSpriteNode(imageNamed: "shopButton")
        shopButton.size = CGSize(width: 80, height: 32)
        shopButton.position = CGPoint(x: leftMargin, y: topY)
        shopButton.zPosition = 10
        shopButton.name = "shopButton"
        addChild(shopButton)

        hudView = HUDView(sceneSize: size, mode: .homeShop)
        addChild(hudView)
        refreshHUD()
    }
    
    private func setupTitle() {
        logoImage = SKSpriteNode(imageNamed: "logo")
        let naturalAspect = logoImage.size.height / max(logoImage.size.width, 1)
        let logoWidth = size.width * 0.65
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

        let subWidth: CGFloat = (subName == "submarine5") ? 130 : 160
        let subAspect = submarine.size.height / max(submarine.size.width, 1)

        submarine.size = CGSize(
            width: subWidth,
            height: subWidth * subAspect
        )

        submarine.position = CGPoint(
            x: size.width / 2,
            y: size.height * 0.40
        )

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

        if touchedNames.contains("startButton") ||
            isTouch(location, inside: startButton, padding: 44) ||
            isTouchInStartArea(location) {
            handleStartButton()
        } else if touchedNames.contains("shopButton") || isTouch(location, inside: shopButton, padding: 24) {
            handleShopButton()
        }
    }

    private func isTouch(_ location: CGPoint, inside node: SKNode, padding: CGFloat) -> Bool {
        node.calculateAccumulatedFrame().insetBy(dx: -padding, dy: -padding).contains(location)
    }

    private func isTouchInStartArea(_ location: CGPoint) -> Bool {
        let startArea = CGRect(
            x: size.width * 0.25,
            y: 0,
            width: size.width * 0.5,
            height: size.height * 0.32
        )
        return startArea.contains(location)
    }
    
    private func handleStartButton() {
        guard !isTransitioningScene else { return }
        isTransitioningScene = true
        transitionToGame()
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
        guard let skView = view else {
            isTransitioningScene = false
            return
        }

        let scene = gameScene(size: SceneSizeProvider.current(for: skView))
        scene.scaleMode = .aspectFill
        scene.gameStateRef = gameStateRef
        skView.presentScene(scene)
    }
    
    private func transitionToShop() {
        gameStateRef?.currentScreen = .shop

        let scene = shopScene(size: SceneSizeProvider.current(for: view))
        scene.scaleMode = .aspectFill
        scene.gameStateRef = gameStateRef
        let transition = SKTransition.fade(withDuration: 0.4)
        self.view?.presentScene(scene, transition: transition)
    }
    
    // MARK: - data refresh
    func refreshHUD() {
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        let totalTrash = UserDefaults.standard.integer(forKey: "totalTrash")
        hudView.distance = highScore
        hudView.trashCount = totalTrash
    }
}

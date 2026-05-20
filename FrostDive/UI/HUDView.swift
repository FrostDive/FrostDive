//
//  HUDView.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit

enum HUDMode {
    case game       // vertical stack di kanan atas + pause button di kiri atas
    case homeShop   // horizontal di kanan atas (tanpa pause button)
}

class HUDView: SKNode {

    // MARK: - Properties
    private var distanceIcon: SKSpriteNode!
    private var trashIcon: SKSpriteNode!
    private var distanceLabel: SKLabelNode!
    private var trashLabel: SKLabelNode!
    private var pauseButton: SKSpriteNode?

    private let mode: HUDMode
    private let sceneSize: CGSize

    // Sizing per mode
    private let distanceIconSize: CGSize
    private let trashIconSize: CGSize
    private let distanceLabelFontSize: CGFloat
    private let trashLabelFontSize: CGFloat

    // Public state
    var distance: Int = 0 {
        didSet {
            distanceLabel.text = "\(distance)m"
            relayout()
        }
    }
    var trashCount: Int = 0 {
        didSet {
            trashLabel.text = "\(trashCount)"
            relayout()
        }
    }

    // MARK: - Init
    init(sceneSize: CGSize, mode: HUDMode = .game) {
        self.sceneSize = sceneSize
        self.mode = mode

        switch mode {
        case .game:
            self.distanceIconSize = CGSize(width: 40, height: 40)
            self.trashIconSize = CGSize(width: 28, height: 28)
            self.distanceLabelFontSize = 22
            self.trashLabelFontSize = 18
        case .homeShop:
            self.distanceIconSize = CGSize(width: 32, height: 26)
            self.trashIconSize = CGSize(width: 31, height: 27)
            self.distanceLabelFontSize = 18
            self.trashLabelFontSize = 18
        }

        super.init()
        setupHUD()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupHUD() {
        zPosition = 100

        switch mode {
        case .game:
            setupGameHUD()
        case .homeShop:
            setupHomeShopHUD()
        }

        relayout()
    }

    private func setupGameHUD() {
        let pause = SKSpriteNode(imageNamed: "pauseIcon")
        pause.size = CGSize(width: 32, height: 32)
        pause.position = CGPoint(x: 64, y: sceneSize.height - 46)
        pause.name = "pauseButton"
        pause.zPosition = 100
        addChild(pause)
        pauseButton = pause

        // Distance (baris atas, kanan)
        distanceLabel = makeLabel(text: "0m", fontSize: distanceLabelFontSize)
        addChild(distanceLabel)

        distanceIcon = SKSpriteNode(imageNamed: "distanceIcon")
        distanceIcon.size = distanceIconSize
        distanceIcon.zPosition = 100
        addChild(distanceIcon)

        // Trash (baris bawah, kanan)
        trashLabel = makeLabel(text: "0", fontSize: trashLabelFontSize)
        addChild(trashLabel)

        trashIcon = SKSpriteNode(imageNamed: "trashIcon")
        trashIcon.size = trashIconSize
        trashIcon.zPosition = 100
        addChild(trashIcon)
    }

    private func setupHomeShopHUD() {
        // Trash (kanan)
        trashLabel = makeLabel(text: "0", fontSize: trashLabelFontSize)
        addChild(trashLabel)

        trashIcon = SKSpriteNode(imageNamed: "trashIcon")
        trashIcon.size = trashIconSize
        trashIcon.zPosition = 100
        addChild(trashIcon)

        // Distance (kiri trash)
        distanceLabel = makeLabel(text: "0m", fontSize: distanceLabelFontSize)
        addChild(distanceLabel)

        distanceIcon = SKSpriteNode(imageNamed: "distanceIcon")
        distanceIcon.size = distanceIconSize
        distanceIcon.zPosition = 100
        addChild(distanceIcon)
    }

    private func makeLabel(text: String, fontSize: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "milner")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.zPosition = 100
        return label
    }

    // MARK: - Layout
    private func relayout() {
        switch mode {
        case .game:
            layoutGame()
        case .homeShop:
            layoutHomeShop()
        }
    }

    private func layoutGame() {
        guard distanceLabel != nil, trashLabel != nil else { return }

        let rightMargin: CGFloat = 32
        let topY = sceneSize.height - 44
        let rowGap: CGFloat = 50
        let iconLabelGap: CGFloat = 6

        // Baris distance (atas)
        let dLabelWidth = distanceLabel.frame.width
        let dIconX = sceneSize.width - rightMargin - distanceIconSize.width / 2
        let dLabelX = dIconX - distanceIconSize.width / 2 - iconLabelGap - dLabelWidth
        distanceLabel.position = CGPoint(x: dLabelX, y: topY)
        distanceIcon.position = CGPoint(x: dIconX, y: topY)

        // Baris trash (bawah)
        let tLabelWidth = trashLabel.frame.width
        let tIconX = sceneSize.width - rightMargin - trashIconSize.width / 2
        let tLabelX = tIconX - trashIconSize.width / 2 - iconLabelGap - tLabelWidth
        trashLabel.position = CGPoint(x: tLabelX, y: topY - rowGap)
        trashIcon.position = CGPoint(x: tIconX, y: topY - rowGap)
    }

    private func layoutHomeShop() {
        guard distanceLabel != nil, trashLabel != nil else { return }

        let topY = sceneSize.height - 35
        let rightMargin: CGFloat = 40
        let iconLabelGap: CGFloat = 6
        let groupGap: CGFloat = 56

        // Group trash (kanan)
        let tLabelWidth = trashLabel.frame.width
        let tIconX = sceneSize.width - rightMargin - trashIconSize.width / 2
        let tLabelX = tIconX - trashIconSize.width / 2 - iconLabelGap - tLabelWidth
        trashLabel.position = CGPoint(x: tLabelX, y: topY)
        trashIcon.position = CGPoint(x: tIconX, y: topY)

        // Group distance (kiri trash)
        let dLabelWidth = distanceLabel.frame.width
        let trashGroupLeftX = tLabelX
        let dIconX = trashGroupLeftX - groupGap - distanceIconSize.width / 2
        let dLabelX = dIconX - distanceIconSize.width / 2 - iconLabelGap - dLabelWidth
        distanceLabel.position = CGPoint(x: dLabelX, y: topY)
        distanceIcon.position = CGPoint(x: dIconX, y: topY)
    }

    // MARK: - API
    func updateDistance(_ meters: Int) {
        distance = meters
    }

    func setTrashCount(_ count: Int) {
        trashCount = count
    }

    func incrementTrash() {
        trashCount += 1
        if mode == .game {
            animateTrashPickup()
        }
    }

    // MARK: - Animations
    private func animateTrashPickup() {
        let pop = SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        trashIcon.run(pop)
        trashLabel.run(pop)

        let plusLabel = SKLabelNode(fontNamed: "milner")
        plusLabel.text = "+1"
        plusLabel.fontSize = 18
        plusLabel.fontColor = SKColor(red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0)
        plusLabel.position = CGPoint(x: trashIcon.position.x, y: trashIcon.position.y + 14)
        plusLabel.zPosition = 101
        addChild(plusLabel)

        let floatUp = SKAction.moveBy(x: 0, y: 24, duration: 0.7)
        let fadeOut = SKAction.fadeOut(withDuration: 0.7)
        let group = SKAction.group([floatUp, fadeOut])
        plusLabel.run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }
}

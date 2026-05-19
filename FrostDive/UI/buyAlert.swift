//
//  buyAlert.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import SpriteKit

class BuyAlertNode: SKNode {

    let subIndex: Int
    let price: Int
    let canAfford: Bool

    init(subIndex: Int, price: Int, canAfford: Bool, sceneSize: CGSize) {
        self.subIndex = subIndex
        self.price = price
        self.canAfford = canAfford
        super.init()

        setup(sceneSize: sceneSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(sceneSize: CGSize) {
        zPosition = 200
        name = "buyAlert"

        let dim = SKShapeNode(rectOf: sceneSize)
        dim.fillColor = SKColor(white: 0, alpha: 0.45)
        dim.strokeColor = .clear
        dim.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        dim.zPosition = -1
        addChild(dim)

        let popupW: CGFloat = 340
        let popupH: CGFloat = 260

        let popup = SKSpriteNode(imageNamed: "popUpShop")
        popup.size = CGSize(width: popupW, height: popupH)
        popup.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        popup.zPosition = 0
        addChild(popup)

        let subTexture = SKTexture(imageNamed: "submarine\(subIndex)")
        let subSprite = SKSpriteNode(texture: subTexture)

        let nativeSize = subTexture.size()
        let maxW: CGFloat = 150
        let maxH: CGFloat = 88

        if nativeSize.width > 0 && nativeSize.height > 0 {
            let scale = min(maxW / nativeSize.width, maxH / nativeSize.height)
            subSprite.size = CGSize(
                width: nativeSize.width * scale,
                height: nativeSize.height * scale
            )
        } else {
            subSprite.size = CGSize(width: 140, height: 80)
        }

        subSprite.position = CGPoint(
            x: sceneSize.width / 2,
            y: sceneSize.height / 2 + popupH * 0.22
        )
        subSprite.zPosition = 1
        addChild(subSprite)

        let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        messageLabel.text = canAfford
            ? "BUY WITH \(formatNumber(price)) TRASH"
            : "TRASH NOT ENOUGH"
        messageLabel.fontSize = canAfford ? 18 : 20
        messageLabel.fontColor = SKColor(red: 0.12, green: 0.25, blue: 0.50, alpha: 1)
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(
            x: sceneSize.width / 2,
            y: sceneSize.height / 2 - popupH * 0.06
        )
        messageLabel.zPosition = 1
        addChild(messageLabel)

        let button = SKSpriteNode(imageNamed: canAfford ? "confirmShop" : "backShop")
        button.size = CGSize(width: canAfford ? 180 : 160, height: 52)
        button.position = CGPoint(
            x: sceneSize.width / 2,
            y: sceneSize.height / 2 - popupH * 0.28
        )
        button.name = canAfford ? "confirmButton" : "popupBackButton"
        button.zPosition = 1
        addChild(button)

        setScale(0.1)
        run(SKAction.scale(to: 1.0, duration: 0.22))
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

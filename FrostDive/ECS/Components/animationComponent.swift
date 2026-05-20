//
//  animationComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit
import SpriteKit
import UIKit

class animationComponent: GKComponent {

    // MARK: - Bubble Effect
    static func addBubbleEffect(
        to node: SKSpriteNode
    ) {

        let spawn = SKAction.run {

            let radius =
                CGFloat.random(in: 2...5)

            let bubble = SKShapeNode(
                circleOfRadius: radius
            )

            bubble.fillColor =
                UIColor.white.withAlphaComponent(0.08)

            bubble.strokeColor =
                UIColor.white.withAlphaComponent(0.45)

            bubble.lineWidth = 1.2

            bubble.glowWidth = 2.5

            bubble.zPosition = -1

            bubble.alpha = 0.7

            bubble.position = CGPoint(
                x: CGFloat.random(in: -4...4),
                y: node.size.height * 0.4
            )

            node.addChild(bubble)

            // Highlight kecil
            let shine = SKShapeNode(
                circleOfRadius: radius * 0.22
            )

            shine.fillColor =
                UIColor.white.withAlphaComponent(0.8)

            shine.strokeColor = .clear

            shine.position = CGPoint(
                x: -radius * 0.3,
                y: radius * 0.3
            )

            bubble.addChild(shine)

            let moveUp = SKAction.moveBy(
                x: CGFloat.random(in: -3...3),
                y: 25,
                duration: 4.0
            )

            moveUp.timingMode = .easeOut

            let scaleDown = SKAction.scale(
                to: 0.1,
                duration: 4.0
            )

            let fadeOut = SKAction.fadeOut(
                withDuration: 4.0
            )

            let group = SKAction.group([
                moveUp,
                scaleDown,
                fadeOut
            ])

            let remove = SKAction.removeFromParent()

            bubble.run(
                SKAction.sequence([
                    group,
                    remove
                ])
            )
        }

        let wait = SKAction.wait(
            forDuration: 2.0
        )

        let sequence = SKAction.sequence([
            spawn,
            wait
        ])

        node.run(
            SKAction.repeatForever(sequence),
            withKey: "bubbleEffect"
        )
    }
    
    

    // MARK: - Magnet glow animation
    static func addMagnetGlow(
        to node: SKSpriteNode,
        size: CGSize
    ) {

        let raysSize = CGSize(
            width: size.width * 1.8,
            height: size.height * 1.8
        )

        let raysTexture = makeLightRaysTexture(
            size: raysSize,
            color: .systemYellow
        )

        let rays = SKSpriteNode(
            texture: raysTexture,
            size: raysSize
        )

        rays.position = .zero
        rays.zPosition = -2
        rays.blendMode = .add
        rays.alpha = 0.6

        node.addChild(rays)

        let rotate = SKAction.rotate(
            byAngle: .pi * 2,
            duration: 8.0
        )

        rays.run(SKAction.repeatForever(rotate))

        let fadeIn = SKAction.fadeAlpha(
            to: 0.7,
            duration: 0.6
        )

        let fadeOut = SKAction.fadeAlpha(
            to: 0.4,
            duration: 0.6
        )

        let pulse = SKAction.sequence([fadeOut, fadeIn])

        rays.run(SKAction.repeatForever(pulse))

        let haloSize = CGSize(
            width: size.width * 2.0,
            height: size.height * 2.0
        )

        let halo = SKSpriteNode(
            texture: makeRadialGlowTexture(
                size: haloSize,
                color: .systemOrange
            ),
            size: haloSize
        )

        halo.position = .zero
        halo.zPosition = -3
        halo.blendMode = .add
        halo.alpha = 0.5

        node.addChild(halo)

        let haloFadeIn = SKAction.fadeAlpha(
            to: 0.7,
            duration: 0.8
        )

        let haloFadeOut = SKAction.fadeAlpha(
            to: 0.3,
            duration: 0.8
        )

        halo.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    haloFadeIn,
                    haloFadeOut,
                ])
            )
        )
    }

    // MARK: - Texture Magnet

    private static func makeLightRaysTexture(
        size: CGSize,
        color: UIColor
    ) -> SKTexture {

        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { ctx in

            let cgContext = ctx.cgContext

            let center = CGPoint(
                x: size.width / 2,
                y: size.height / 2
            )

            let maxRadius =
                min(size.width, size.height) / 2

            let rayCount = 8
            let rayAngleWidth: CGFloat = 0.25

            for i in 0..<rayCount {

                let baseAngle =
                    (CGFloat.pi * 2 / CGFloat(rayCount))
                    * CGFloat(i)

                let leftAngle =
                    baseAngle - rayAngleWidth / 2

                let rightAngle =
                    baseAngle + rayAngleWidth / 2

                let leftPoint = CGPoint(
                    x: center.x + cos(leftAngle) * maxRadius,
                    y: center.y + sin(leftAngle) * maxRadius
                )

                let rightPoint = CGPoint(
                    x: center.x + cos(rightAngle) * maxRadius,
                    y: center.y + sin(rightAngle) * maxRadius
                )

                let path = CGMutablePath()

                path.move(to: center)
                path.addLine(to: leftPoint)
                path.addLine(to: rightPoint)
                path.closeSubpath()

                cgContext.saveGState()
                cgContext.addPath(path)
                cgContext.clip()

                let colors =
                    [
                        color.withAlphaComponent(1.0).cgColor,
                        color.withAlphaComponent(0.4).cgColor,
                        color.withAlphaComponent(0.0).cgColor,
                    ] as CFArray

                let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: colors,
                    locations: [0.0, 0.5, 1.0]
                )!

                cgContext.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: maxRadius,
                    options: []
                )

                cgContext.restoreGState()
            }
        }

        return SKTexture(image: image)
    }

    private static func makeRadialGlowTexture(
        size: CGSize,
        color: UIColor
    ) -> SKTexture {

        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { ctx in

            let center = CGPoint(
                x: size.width / 2,
                y: size.height / 2
            )

            let radius =
                min(size.width, size.height) / 2

            let colors =
                [
                    color.withAlphaComponent(0.8).cgColor,
                    color.withAlphaComponent(0.3).cgColor,
                    color.withAlphaComponent(0.0).cgColor,
                ] as CFArray

            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0.0, 0.4, 1.0]
            )!

            ctx.cgContext.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }

        return SKTexture(image: image)
    }
}

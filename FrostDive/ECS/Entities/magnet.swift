//
//  magnet.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import GameplayKit
import SpriteKit

class magnetEntity: GKEntity {
    init(
        imageName: String,
        size: CGSize,
        startPosition: CGPoint,
        speed: CGFloat
    ) {
        super.init()

        let texture: SKTexture = .init(imageNamed: imageName)

        // 1. Data Posisi & Visual
        addComponent(positionComponent(position: startPosition))
        addComponent(spriteComponent(texture: texture, size: size))

        // 2. Data Gerak (Ini yang membuat dia bisa bergerak)
        addComponent(movementComponent(speed: speed))

        // 3. Konfigurasi Fisika
        if let spriteNode = component(ofType: spriteComponent.self)?.node {
            spriteNode.name = "magnet"
            spriteNode.physicsBody = SKPhysicsBody(texture: texture, size: size)
            spriteNode.physicsBody?.isDynamic = false  // Agar tidak jatuh kena gravitasi
            spriteNode.physicsBody?.categoryBitMask = physicsCategory.power
            spriteNode.physicsBody?.contactTestBitMask =
                physicsCategory.submarine
            spriteNode.physicsBody?.collisionBitMask = physicsCategory.none

            magnetEntity.addGlowEffect(to: spriteNode, size: size)
        }

    }
    // MARK: - Light Rays (sinar memancar seperti Subway Surfers)
    private static func addGlowEffect(to node: SKSpriteNode, size: CGSize) {
        let raysSize = CGSize(width: size.width * 1.8, height: size.height * 1.8)
        let raysTexture = makeLightRaysTexture(size: raysSize, color: .systemYellow)
        
        let rays = SKSpriteNode(texture: raysTexture, size: raysSize)
        rays.position = .zero
        rays.zPosition = -2            // Paling belakang
        rays.blendMode = .add          // Bikin bercahaya
        rays.alpha = 0.6
        rays.name = "magnetRays"
        node.addChild(rays)
        
        // Animasi 1: Rotasi pelan supaya hidup
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 8.0)
        rays.run(SKAction.repeatForever(rotate), withKey: "raysRotate")
        
        // Animasi 2: Pulse alpha (terang-redup-terang)
        let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.6)
        let fadeOut = SKAction.fadeAlpha(to: 0.4, duration: 0.6)
        fadeIn.timingMode = .easeInEaseOut
        fadeOut.timingMode = .easeInEaseOut
        
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        rays.run(SKAction.repeatForever(pulse), withKey: "raysPulse")
        
        // Tambah glow halo bulat lembut DI BELAKANG rays untuk depth
        let halo = SKSpriteNode(
            texture: makeRadialGlowTexture(
                size: CGSize(width: size.width * 2.0, height: size.height * 2.0),
                color: .systemOrange
            ),
            size: CGSize(width: size.width * 2.0, height: size.height * 2.0)
        )
        halo.position = .zero
        halo.zPosition = -3
        halo.blendMode = .add
        halo.alpha = 0.5
        halo.name = "magnetHalo"
        node.addChild(halo)
        
        // Halo juga pulse, tapi delay-nya beda biar gak sinkron
        let haloFadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.8)
        let haloFadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.8)
        halo.run(SKAction.repeatForever(SKAction.sequence([haloFadeIn, haloFadeOut])))
    }

    // MARK: - Light Rays Texture Generator
    private static func makeLightRaysTexture(size: CGSize, color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cgContext = ctx.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let maxRadius = min(size.width, size.height) / 2
            
            let rayCount = 8                       // Jumlah sinar
            let rayAngleWidth: CGFloat = 0.25      // Lebar tiap sinar (radian) ~14°
            
            for i in 0..<rayCount {
                let baseAngle = (CGFloat.pi * 2 / CGFloat(rayCount)) * CGFloat(i)
                
                // Gambar tiap sinar sebagai segitiga panjang (triangle path)
                let leftAngle = baseAngle - rayAngleWidth / 2
                let rightAngle = baseAngle + rayAngleWidth / 2
                
                let leftPoint = CGPoint(
                    x: center.x + cos(leftAngle) * maxRadius,
                    y: center.y + sin(leftAngle) * maxRadius
                )
                let rightPoint = CGPoint(
                    x: center.x + cos(rightAngle) * maxRadius,
                    y: center.y + sin(rightAngle) * maxRadius
                )
                
                // Buat gradient untuk tiap ray (terang di tengah, fade ke ujung)
                let path = CGMutablePath()
                path.move(to: center)
                path.addLine(to: leftPoint)
                path.addLine(to: rightPoint)
                path.closeSubpath()
                
                cgContext.saveGState()
                cgContext.addPath(path)
                cgContext.clip()
                
                // Radial gradient di dalam ray
                let colors = [
                    color.withAlphaComponent(1.0).cgColor,
                    color.withAlphaComponent(0.4).cgColor,
                    color.withAlphaComponent(0.0).cgColor
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

    // MARK: - Radial Glow Texture (halo bulat di belakang rays)
    private static func makeRadialGlowTexture(size: CGSize, color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            let colors = [
                color.withAlphaComponent(0.8).cgColor,
                color.withAlphaComponent(0.3).cgColor,
                color.withAlphaComponent(0.0).cgColor
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

    required init?(coder aDecoder: NSCoder) { fatalError() }
}

//
//  gameScene.swift
//  FrostDive
//
//  Created by Natalie Grace Widjaja Kuswanto on 13/05/26.
//

import GameplayKit
import SpriteKit

// MARK: - Enums
enum ObstacleType: CaseIterable {
    case bomb, iceberg1, iceberg2, iceberg3, iceberg4

    var imageName: String {
        switch self {
        case .bomb: return "bomb"
        case .iceberg1: return "iceberg1"
        case .iceberg2: return "iceberg2"
        case .iceberg3: return "iceberg3"
        case .iceberg4: return "iceberg4"
        }
    }

    var size: CGSize {
        switch self {
        case .bomb: return CGSize(width: 43, height: 61)
        case .iceberg1: return CGSize(width: 240, height: 236)
        case .iceberg2: return CGSize(width: 240, height: 156)
        case .iceberg3: return CGSize(width: 240, height: 108)
        case .iceberg4: return CGSize(width: 240, height: 166)
        }
    }
}

class gameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties
    var entities = [GKEntity]()
    var playerEntity: submarineEntity?
    var gameState: gameState?

    // Systems
    lazy var posSystem = positionSystem(componentClass: positionComponent.self)
    lazy var moveSystem = MovementSystem(sceneSize: self.size)
    lazy var thrustSys = thrustSystem()

    // Time tracking untuk mencegah glitch pergerakan
    var lastUpdateTime: TimeInterval = 0

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        soundComponent.shared.setupAudioSession()

        setupPhysics()
        setupEdge()
        setupBackground()
        spawnSubmarine()

        soundComponent.shared.playBGM(scene: self)

        startSpawning()

        let seconds = 15.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.startMagnetSpawning()
        }

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerEntity?.component(ofType: thrustComponent.self)?.isThrusting =
            true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerEntity?.component(ofType: thrustComponent.self)?.isThrusting =
            false
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        var dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Batasi dt agar tidak meloncat jauh kalau ada frame drop
        if dt > 0.05 { dt = 1.0 / 60.0 }

        // 1. Update status magnet dari gameState
        moveSystem.isMagnetActive = gameState?.isMagnetic ?? false

        // 2. Kirim posisi kapal selam mengambil dari spriteNode
        if let subNode = playerEntity?.component(ofType: spriteComponent.self)?
            .node
        {
            moveSystem.submarinePosition = subNode.position
        }

        // Jalankan sistem
        thrustSys.update(deltaTime: dt)
        moveSystem.update(deltaTime: dt)
        posSystem.update(deltaTime: dt)

        cleanupOffScreenEntities()
    }
}

// MARK: - Setup (Pengaturan Awal)
extension gameScene {

    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
    }

    private func setupEdge() {
        let edgeFrame = CGRect(
            x: 0,
            y: 0,
            width: size.width,
            height: size.height
        )
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: edgeFrame)
        self.physicsBody?.categoryBitMask = physicsCategory.edge
    }

    private func setupBackground() {
        let bgSpeed: CGFloat = 3.0

        for i in 0..<15 {
            let imageName = "background_\(i + 1)"
            let startX = CGFloat(i) * size.width
            let startPos = CGPoint(x: startX, y: 0)

            let bg = backgroundEntity(
                imageName: imageName,
                size: self.size,
                startPosition: startPos,
                speed: bgSpeed,
                index: i
            )

            if let p = bg.component(ofType: positionComponent.self) {
                posSystem.addComponent(p)
            }
            if let m = bg.component(ofType: movementComponent.self) {
                moveSystem.addComponent(m)
            }

            if let s = bg.component(ofType: spriteComponent.self) {
                s.node.anchorPoint = CGPoint(x: 0, y: 0)
                s.node.zPosition = -10
                addChild(s.node)
            }

            entities.append(bg)
        }
    }

    private func spawnSubmarine() {
        let startPos = CGPoint(x: size.width * 0.2, y: size.height / 2)
        let submarine = submarineEntity(
            imageName: "submarine1",
            size: CGSize(width: 120, height: 82),
            startPosition: startPos
        )

        // Simpan ke variabel playerEntity agar mudah diakses saat layar disentuh
        self.playerEntity = submarine

        // Daftarkan ke sistem
        if let t = submarine.component(ofType: thrustComponent.self) {
            thrustSys.addComponent(t)
        }

        if let s = submarine.component(ofType: spriteComponent.self) {
            s.node.position = startPos
            addChild(s.node)
        }

        entities.append(submarine)
    }
}

// MARK: - Spawning Logic
extension gameScene {

    private func startSpawning() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnRandomEntity()
        }
        let randomDelay = TimeInterval.random(in: 2.0...3.5)
        let delaySpawn = SKAction.wait(forDuration: randomDelay)
        let sequence = SKAction.sequence([spawnAction, delaySpawn])

        run(SKAction.repeatForever(sequence), withKey: "entity_spawn")

    }

    private func startMagnetSpawning() {
        // logic spawn magnet

        let spawnMagnet = SKAction.run { [weak self] in
            self?.spawnMagnetEntity()
        }

        let randomMagnetDelay = TimeInterval.random(in: 20.0...30.0)
        let delayMagnet = SKAction.wait(forDuration: randomMagnetDelay)
        let sequenceMagnet = SKAction.sequence([spawnMagnet, delayMagnet])

        run(SKAction.repeatForever(sequenceMagnet), withKey: "magnet_spawn")
    }

    private func spawnRandomEntity() {
        let isTrash = Bool.random()
        let speed: CGFloat = 3.0
        let startX = size.width + 100

        let newEntity: GKEntity
        var startPos: CGPoint = .zero

        if isTrash {
            let randomTrashIndex = Int.random(in: 1...3)
            let trashImageName = "trash_\(randomTrashIndex)"
            let trashSize = CGSize(width: 43, height: 69)

            let safeMargin: CGFloat = 100 + (trashSize.height / 2)
            let randomY = CGFloat.random(
                in: safeMargin...(size.height - safeMargin)
            )
            startPos = CGPoint(x: startX, y: randomY)

            newEntity = trashEntity(
                imageName: trashImageName,
                size: trashSize,
                startPosition: startPos,
                speed: speed
            )

        } else {
            let randomObstacle = ObstacleType.allCases.randomElement()!
            let halfHeight = randomObstacle.size.height / 2
            let overlapOffset: CGFloat = 20

            switch randomObstacle {
            case .bomb:
                let safeMargin: CGFloat = 100 + halfHeight
                let randomY = CGFloat.random(
                    in: safeMargin...(size.height - safeMargin)
                )
                startPos = CGPoint(x: startX, y: randomY)
            case .iceberg1, .iceberg2:
                startPos = CGPoint(
                    x: startX,
                    y: size.height - halfHeight + overlapOffset
                )
            case .iceberg3, .iceberg4:
                startPos = CGPoint(x: startX, y: halfHeight - overlapOffset)
            }

            newEntity = obstacleEntity(
                imageName: randomObstacle.imageName,
                size: randomObstacle.size,
                startPosition: startPos,
                speed: speed
            )
        }

        if let s = newEntity.component(ofType: spriteComponent.self) {
            s.node.position = startPos
            addChild(s.node)
        }

        if let p = newEntity.component(ofType: positionComponent.self) {
            posSystem.addComponent(p)
        }
        if let m = newEntity.component(ofType: movementComponent.self) {
            moveSystem.addComponent(m)
        }

        entities.append(newEntity)
    }

    private func spawnMagnetEntity() {

        let speed: CGFloat = 2.5
        let startX = size.width + 100
        let newEntity: GKEntity
        var startPos: CGPoint = .zero

        let magnetImageName = "magnet"
        let magnetSize = CGSize(width: 70, height: 69)

        let safeMargin: CGFloat = 100 + (magnetSize.height / 2)
        let randomY = CGFloat.random(
            in: safeMargin...(size.height - safeMargin)
        )
        startPos = CGPoint(x: startX, y: randomY)

        newEntity = magnetEntity(
            imageName: magnetImageName,
            size: magnetSize,
            startPosition: startPos,
            speed: speed
        )

        if let s = newEntity.component(ofType: spriteComponent.self) {
            s.node.position = startPos
            addChild(s.node)

            if let p = newEntity.component(ofType: positionComponent.self) {
                posSystem.addComponent(p)
            }
            if let m = newEntity.component(ofType: movementComponent.self) {
                moveSystem.addComponent(m)
            }

            entities.append(newEntity)
        }
    }
}

// MARK: - Cleanup System
extension gameScene {

    private func cleanupOffScreenEntities() {
        // Fungsi ini akan mengecek semua entity, dan MENGHAPUSNYA jika return true
        entities.removeAll { entity in

            // 1. Pastikan dia adalah trash atau obstacle
            guard entity is trashEntity || entity is obstacleEntity else {
                return false
            }

            // 2. Cek apakah posisinya sudah jauh di luar layar kiri
            guard
                let posComp = entity.component(ofType: positionComponent.self),
                posComp.position.x < -500
            else { return false }

            // 3. Jika iya, eksekusi pembersihannya
            entity.component(ofType: spriteComponent.self)?.node
                .removeFromParent()

            if let moveComp = entity.component(ofType: movementComponent.self) {
                moveSystem.removeComponent(moveComp)
            }
            posSystem.removeComponent(posComp)

            // 4. Return true agar Swift otomatis membuangnya dari array 'entities'
            return true
        }
    }
}

// MARK: - Collision / Contact Logic
extension gameScene {

    func didBegin(_ contact: SKPhysicsContact) {

        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        let collision = bodyA | bodyB

        if collision == physicsCategory.submarine | physicsCategory.trash {
            let trashNode =
                bodyA == physicsCategory.trash
                ? contact.bodyA.node : contact.bodyB.node

            soundComponent.shared.playCollectSound(scene: self)

            print("Sampah dikumpulkan!")

            guard trashNode?.name == "trash" else { return }
            trashNode?.name = "collected"
            trashNode?.removeFromParent()

        } else if collision == physicsCategory.submarine
            | physicsCategory.obstacle
        {
            soundComponent.shared.obstacleHaptic()

            soundComponent.shared.playExplosionSound(scene: self)

            soundComponent.shared.stopBGM()

        } else if collision == physicsCategory.submarine | physicsCategory.power
        {
            let powerNode =
                bodyA == physicsCategory.power
                ? contact.bodyA.node : contact.bodyB.node

            print("Power-up diambil!")

            guard powerNode?.name == "magnet" else { return }
            powerNode?.name = "collected"
            powerNode?.removeFromParent()

            // 1. Ubah state menjadi true
            self.gameState?.isMagnetic = true

            // 2. Buat aksi menunggu 10 detik
            let waitAction = SKAction.wait(forDuration: 10.0)

            // 3. Buat aksi untuk mematikan magnet
            let turnOffAction = SKAction.run { [weak self] in
                self?.gameState?.isMagnetic = false
                print("Efek magnet telah habis!")
            }

            // 4. Rangkai aksinya
            let magnetSequence = SKAction.sequence([waitAction, turnOffAction])

            // 5. Jalankan dengan Key.
            // Jika pemain ambil magnet lagi di detik ke-9, timer lama akan otomatis ditimpa timer baru!
            self.run(magnetSequence, withKey: "magnet_timer")
        } else if collision == physicsCategory.submarine
            | physicsCategory.obstacle
        {
            print("GAME OVER: Menabrak rintangan!")

            removeAction(forKey: "entity_spawn")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.playerEntity?.component(ofType: spriteComponent.self)?.node
                    .removeFromParent()
            }
            removeAction(forKey: "magnet_spawn")

            playerEntity?.component(ofType: spriteComponent.self)?.node
                .removeFromParent()

        }
    }
}

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
    
    func getStartPosition(sceneSize: CGSize, startX: CGFloat) -> CGPoint {
        let halfHeight = self.size.height / 2
        
        switch self {
        case .bomb:
            let safeMargin: CGFloat = 100 + halfHeight
            let randomY = CGFloat.random(in: safeMargin...(sceneSize.height - safeMargin))
            return CGPoint(x: startX, y: randomY)
            
        case .iceberg1:
            return CGPoint(x: startX, y: sceneSize.height - halfHeight + 50)
        case .iceberg2:
            // Iceberg atap (muncul di atas)
            return CGPoint(x: startX, y: sceneSize.height - halfHeight + 30)
            
        case .iceberg3:
            return CGPoint(x: startX, y: halfHeight - 30)
            
        case .iceberg4:
            // Iceberg dasar laut (muncul di bawah)
            return CGPoint(x: startX, y: halfHeight - 20)
        }
    }
}

class gameScene: SKScene, SKPhysicsContactDelegate {
    
    static var hasShownTutorialThisSession = false
    var isTutorialActive = false
    var tutorialNode: SKSpriteNode?
    
    // MARK: - Properties
    var entities = [GKEntity]()
    var playerEntity: submarineEntity?
    var gameStateRef: gameState?
    
    // Systems
    lazy var posSystem = positionSystem(componentClass: positionComponent.self)
    lazy var moveSystem = MovementSystem(sceneSize: self.size)
    lazy var thrustSys = thrustSystem()
    
    private var hud: HUDView!
    private var sessionDistance: Double = 0
    private var sessionTrash: Int = 0
    private var hasSavedSession = false
    private var wasGameOver = false
    
    // Time tracking untuk mencegah glitch pergerakan
    var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        gameStateRef?.currentScreen = .game
        gameStateRef?.shouldReturnHome = false
        gameStateRef?.isPaused = false
        gameStateRef?.isGameOver = false
        gameStateRef?.isMagnetic = false
        gameStateRef?.trash = 0
        gameStateRef?.distance = 0
        soundComponent.shared.setupAudioSession()
        
        
        setupPhysics()
        setupEdge()
        setupBackground()
        spawnSubmarine()
        setupHUD()
        
        soundComponent.shared.playBGM(scene: self)
        
        if !gameScene.hasShownTutorialThisSession {
            showTutorial()
        } else {
            startGameplay()
        }
        
    }
    
    private func setupHUD() {
        hud = HUDView(sceneSize: size, mode: .game)
        
        hud.zPosition = 100
        
        addChild(hud)
        hud.distance = 0
        hud.trashCount = 0
    }
    
    private func saveSessionResults() {
        guard !hasSavedSession else { return }
        hasSavedSession = true
        
        let savedTotal = UserDefaults.standard.integer(forKey: "totalTrash")
        UserDefaults.standard.set(
            savedTotal + sessionTrash,
            forKey: "totalTrash"
        )
        
        let savedHigh = UserDefaults.standard.integer(forKey: "highScore")
        let sessionMeters = Int(sessionDistance)
        if sessionMeters > savedHigh {
            UserDefaults.standard.set(sessionMeters, forKey: "highScore")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isTutorialActive {
            dismissTutorial()
            return // Jangan lakukan apa-apa lagi (kapal tidak akan melompat di tap pertama)
        }
        
        if gameStateRef?.isPaused == true || gameStateRef?.isGameOver == true {
            return
        }
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            for node in nodes(at: location) {
                if node.name == "pauseButton" {
                    soundComponent.shared.playButtonSound()

                    gameStateRef?.isPaused = true
                    return
                }
            }
        }
        
        playerEntity?.component(ofType: thrustComponent.self)?.isThrusting =
        true
        playerEntity?.component(ofType: thrustComponent.self)?.isThrusting =
        true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerEntity?.component(ofType: thrustComponent.self)?.isThrusting =
        false
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if isTutorialActive { return }
        
        if gameStateRef?.shouldReturnHome == true {
            navigateHome()
            return
        }
        
        if wasGameOver, gameStateRef?.isGameOver == false {
            wasGameOver = false
            restartGame()
            return
        }
        
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        var dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Batasi dt agar tidak meloncat jauh kalau ada frame drop
        if dt > 0.05 { dt = 1.0 / 60.0 }
        
        if gameStateRef?.isPaused == true || gameStateRef?.isGameOver == true {
            
            self.speed = 0
            self.physicsWorld.speed = 0
            
            soundComponent.shared.pauseMusic()

            if gameStateRef?.isGameOver == true { wasGameOver = true }
            return
        } else {
            
            self.speed = 1
            self.physicsWorld.speed = 1
            
            soundComponent.shared.resumeMusic()
        }
        
        if !hasSavedSession {
            sessionDistance += dt * 10
            hud?.distance = Int(sessionDistance)
        }
        
        let currentSpeedMultiplier = 1.0 + (CGFloat(sessionDistance) / 2000.0)
        
        if !hasSavedSession {
            let baseDistanceRate: Double = 10.0 // Angka dasar pertambahan jarak
            
            // Jarak bertambah makin cepat seiring naiknya multiplier
            sessionDistance += dt * baseDistanceRate * Double(currentSpeedMultiplier)
            hud?.distance = Int(sessionDistance)
        }
        
        // 1. Update status magnet dari gameState
        moveSystem.isMagnetActive = gameStateRef?.isMagnetic ?? false
        
        moveSystem.speedMultiplier = currentSpeedMultiplier
        
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
    
    private func navigateHome() {
        self.speed = 1
        self.physicsWorld.speed = 1
        
        soundComponent.shared.stopBGM()
        
        gameStateRef?.isPaused = false
        gameStateRef?.isGameOver = false
        gameStateRef?.shouldReturnHome = false
        gameStateRef?.currentScreen = .home
        
        let home = homeScene(size: SceneSizeProvider.current(for: view))
        home.scaleMode = .aspectFill
        home.gameStateRef = gameStateRef
        view?.presentScene(
            home,
            transition: SKTransition.fade(withDuration: 0.4)
        )
    }
    
    private func restartGame() {
        
        self.speed = 1
        self.physicsWorld.speed = 1
        
        soundComponent.shared.stopBGM()
        
        gameStateRef?.currentScreen = .game
        gameStateRef?.shouldReturnHome = false
        gameStateRef?.isPaused = false
        gameStateRef?.isGameOver = false
        
        let fresh = gameScene(size: SceneSizeProvider.current(for: view))
        fresh.scaleMode = .aspectFill
        fresh.gameStateRef = gameStateRef
        view?.presentScene(
            fresh,
            transition: SKTransition.fade(withDuration: 0.3)
        )
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
        let speed: CGFloat = 3.0
        
        for i in 0..<15 {
            let imageName = "background_\(i + 1)"
            let startX = CGFloat(i) * size.width
            let startPos = CGPoint(x: startX, y: 0)
            
            let bg = backgroundEntity(
                imageName: imageName,
                size: self.size,
                startPosition: startPos,
                speed: speed,
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
        let equippedSub = UserDefaults.standard.integer(
            forKey: "equippedSubmarine"
        )
        let subIndex: Int
        if equippedSub <= 0 {
            subIndex = 1
        } else {
            subIndex = min(max(equippedSub,1),6)
        }
        
        let startPos = CGPoint(x: size.width * 0.2, y: size.height / 2)
        let submarine = submarineEntity(
            type: .normal(subIndex),
            startPosition: startPos
        )
        
        // Simpan ke variabel playerEntity agar mudah diakses saat layar disentuh
        self.playerEntity = submarine
        
        // Daftarkan ke sistem
        if let t = submarine.component(ofType: thrustComponent.self) {
            thrustSys.addComponent(t)
        }
        
        let flashlight = flashlightComponent(scene: self)
        submarine.addComponent(flashlight)
        flashlight.startLightingCycle()
        
        if let s = submarine.component(ofType: spriteComponent.self) {
            s.node.position = startPos
            addChild(s.node)
        }
        
        entities.append(submarine)
    }
    
    // MARK: - Tutorial & Gameplay Flow
    
    private func showTutorial() {
        isTutorialActive = true
        
        // Bekukan waktu game sepenuhnya
        self.speed = 0
        self.physicsWorld.speed = 0
        
        // Tampilkan gambar instruksi
        let tutorial = SKSpriteNode(imageNamed: "attention") // Sesuaikan nama asetmu
        tutorial.position = CGPoint(x: size.width / 2, y: size.height / 2)
        tutorial.zPosition = 300 // Pastikan berada paling depan menutupi HUD
        tutorial.name = "tutorialNode"
        
        // Opsional: Sesuaikan skala jika gambarnya terlalu besar/kecil
        // tutorial.setScale(0.8)
        
        addChild(tutorial)
        tutorialNode = tutorial
    }
    
    private func dismissTutorial() {
        isTutorialActive = false
        gameScene.hasShownTutorialThisSession = true // Tandai agar tidak muncul lagi
        
        // Buang gambar dari layar
        tutorialNode?.removeFromParent()
        tutorialNode = nil
        
        startGameplay()
    }
    
    private func startGameplay() {
        // Cairkan waktu game
        self.speed = 1
        self.physicsWorld.speed = 1
        
        // Mulai munculkan musuh dan magnet dan ikan
        startSpawning()
        startFishSpawning()
        
        let seconds = 15.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            self?.startMagnetSpawning()
        }
    }
}

// MARK: - Spawning Logic
extension gameScene {
    
    // MARK: - 1. Pemicu Spawning (Dinamis)
    private func startSpawning() {
        spawnRandomPatternAndScheduleNext()
    }
    
    private func spawnRandomPatternAndScheduleNext() {
        let isTrash = Bool.random()
        let startX = size.width + 100
        var patternDelay: TimeInterval = 2.5 // Jeda default
        
        if isTrash {
            let pattern = Int.random(in: 1...3)
            switch pattern {
            case 1:
                spawnTrashGrid(startX: startX)
                patternDelay = 2.0 // Grid lumayan padat
            case 2:
                spawnTrashZigZag(startX: startX)
                patternDelay = 3.5 // Zigzag butuh ruang panjang ke belakang
            case 3:
                spawnTrashLine(startX: startX)
                patternDelay = 2.5
            default: break
            }
        } else {
            let pattern = Int.random(in: 4...8)
            switch pattern {
            case 4:
                spawnBombWallTopGap(startX: startX)
                patternDelay = 2.5
            case 5:
                spawnBombWallBottomGap(startX: startX)
                patternDelay = 2.5
            case 6:
                spawnBombWallMiddleGap(startX: startX)
                patternDelay = 2.5
            case 7:
                spawnIcebergAlternating1(startX: startX)
                patternDelay = 7.0 // SANGAT PANJANG! Jeda harus lama agar tidak bertabrakan
            case 8:
                spawnIcebergAlternating2(startX: startX)
                patternDelay = 7.0 // SANGAT PANJANG!
            default: break
            }
        }
        
        // Tambahkan elemen acak kecil agar jedanya tidak terasa kaku
        let finalDelay = patternDelay + TimeInterval.random(in: 0...0.8)
        
        let waitAction = SKAction.wait(forDuration: finalDelay)
        let nextSpawn = SKAction.run { [weak self] in
            self?.spawnRandomPatternAndScheduleNext()
        }
        
        // Panggil dirinya sendiri (Rekursif) dengan jeda waktu yang dinamis
        let sequence = SKAction.sequence([waitAction, nextSpawn])
        run(sequence, withKey: "entity_spawn")
    }
    
    // MARK: - 2. Pembantu (Helpers) Pembentuk Entity
    private func createTrash(at position: CGPoint) {
        let randomTrashIndex = Int.random(in: 1...3)
        let trashImageName = "trash_\(randomTrashIndex)"
        let trashSize = CGSize(width: 26, height: 42)
        
        let newEntity = trashEntity(imageName: trashImageName, size: trashSize, startPosition: position, speed: 3.0)
        finalizeSpawn(entity: newEntity, startPos: position)
    }
    
    private func createObstacle(type: ObstacleType, at position: CGPoint) {
        let newEntity = obstacleEntity(imageName: type.imageName, size: type.size, startPosition: position, speed: 3.0)
        finalizeSpawn(entity: newEntity, startPos: position)
    }
    
    private func finalizeSpawn(entity: GKEntity, startPos: CGPoint) {
        if let s = entity.component(ofType: spriteComponent.self) {
            s.node.position = startPos
            addChild(s.node)
        }
        if let p = entity.component(ofType: positionComponent.self) { posSystem.addComponent(p) }
        if let m = entity.component(ofType: movementComponent.self) { moveSystem.addComponent(m) }
        entities.append(entity)
    }
    
    // MARK: - 3. Daftar Pola (Patterns)
    
    // CASE 1: Grid Sampah 3 Baris x 5 Kolom
    private func spawnTrashGrid(startX: CGFloat) {
        let cols = 5
        let rows = 3
        let spacingX: CGFloat = 45
        let spacingY: CGFloat = 55
        let gridHeight = CGFloat(rows - 1) * spacingY
        
        let safeMargin = 100 + (gridHeight / 2)
        let baseY = CGFloat.random(in: safeMargin...(size.height - safeMargin))
        
        for col in 0..<cols {
            for row in 0..<rows {
                let x = startX + CGFloat(col) * spacingX
                let y = baseY + (CGFloat(row) * spacingY) - (gridHeight / 2)
                createTrash(at: CGPoint(x: x, y: y))
            }
        }
    }
    
    // CASE 2: ZigZag Sampah (2 Gunung, 2 Lembah)
    private func spawnTrashZigZag(startX: CGFloat) {
        // Angka ini melambangkan posisi Y: Tengah(0), Atas(1), Tengah(0), Bawah(-1)
        let yMultipliers: [CGFloat] = [0, 1, 0, -1, 0, 1, 0, -1, 0]
        let spacingX: CGFloat = 50
        let waveHeight: CGFloat = 80 // Tingkat kecuraman zigzag
        
        let safeMargin = 100 + waveHeight
        let baseY = CGFloat.random(in: safeMargin...(size.height - safeMargin))
        
        for (index, mult) in yMultipliers.enumerated() {
            let x = startX + CGFloat(index) * spacingX
            let y = baseY + (mult * waveHeight)
            createTrash(at: CGPoint(x: x, y: y))
        }
    }
    
    // CASE 3: Garis Lurus Sampah
    private func spawnTrashLine(startX: CGFloat) {
        let count = 7
        let spacingX: CGFloat = 45
        let baseY = CGFloat.random(in: 100...(size.height - 100))
        
        for i in 0..<count {
            let x = startX + CGFloat(i) * spacingX
            createTrash(at: CGPoint(x: x, y: baseY))
        }
    }
    
    // CASE 4: Tembok Bom (Celah di Atas)
    private func spawnBombWallTopGap(startX: CGFloat) {
        let padding: CGFloat = 15
        let step = ObstacleType.bomb.size.height + padding
        let gapHeight: CGFloat = 220 // Area kosong untuk kapal lewat
        
        let maxY = size.height - gapHeight
        var currentY: CGFloat = 50 // Mulai susun dari bawah ke atas
        
        while currentY < maxY {
            createObstacle(type: .bomb, at: CGPoint(x: startX, y: currentY))
            currentY += step
        }
    }
    
    // CASE 5: Tembok Bom (Celah di Bawah)
    private func spawnBombWallBottomGap(startX: CGFloat) {
        let padding: CGFloat = 15
        let step = ObstacleType.bomb.size.height + padding
        let gapHeight: CGFloat = 220
        
        let minY = gapHeight
        var currentY = size.height - 50 // Mulai susun dari atas ke bawah
        
        while currentY > minY {
            createObstacle(type: .bomb, at: CGPoint(x: startX, y: currentY))
            currentY -= step
        }
    }
    
    // CASE 6: Tembok Bom Split (Celah di Tengah Layar)
    private func spawnBombWallMiddleGap(startX: CGFloat) {
        let padding: CGFloat = 15
        let step = ObstacleType.bomb.size.height + padding
        let gapHeight: CGFloat = 250 // Celah tengah sedikit lebih besar karena sulit masuk
        
        let middleY = size.height / 2
        let gapBottom = middleY - (gapHeight / 2)
        let gapTop = middleY + (gapHeight / 2)
        
        // Susun pilar bawah
        var currentY: CGFloat = 50
        while currentY < gapBottom {
            createObstacle(type: .bomb, at: CGPoint(x: startX, y: currentY))
            currentY += step
        }
        
        // Susun pilar atas
        currentY = gapTop
        while currentY < size.height - 20 {
            createObstacle(type: .bomb, at: CGPoint(x: startX, y: currentY))
            currentY += step
        }
    }
    
    // CASE 7: Iceberg Bergantian (Atas - Bawah - Atas - Bawah)
    private func spawnIcebergAlternating1(startX: CGFloat) {
        let spacingX: CGFloat = 200 // Jarak antar iceberg
        let types: [ObstacleType] = [.iceberg1, .iceberg3, .iceberg1, .iceberg3]
        
        for (index, type) in types.enumerated() {
            let x = startX + CGFloat(index) * spacingX
            let y = type.getStartPosition(sceneSize: size, startX: x).y // Manfaatkan enum milikmu!
            createObstacle(type: type, at: CGPoint(x: x, y: y))
        }
    }
    
    // CASE 8: Iceberg Bergantian (Bawah - Atas - Bawah - Atas)
    private func spawnIcebergAlternating2(startX: CGFloat) {
        let spacingX: CGFloat = 200
        let types: [ObstacleType] = [.iceberg4, .iceberg2, .iceberg4, .iceberg2]
        
        for (index, type) in types.enumerated() {
            let x = startX + CGFloat(index) * spacingX
            let y = type.getStartPosition(sceneSize: size, startX: x).y
            createObstacle(type: type, at: CGPoint(x: x, y: y))
        }
    }
    
    // MARK: - Magnet Spawning (Sama seperti sebelumnya)
    private func startMagnetSpawning() {
        let spawnMagnet = SKAction.run { [weak self] in
            self?.spawnMagnetEntity()
        }
        let randomMagnetDelay = TimeInterval.random(in: 20.0...30.0)
        let delayMagnet = SKAction.wait(forDuration: randomMagnetDelay)
        let sequenceMagnet = SKAction.sequence([spawnMagnet, delayMagnet])
        
        run(SKAction.repeatForever(sequenceMagnet), withKey: "magnet_spawn")
    }
    
    private func spawnMagnetEntity() {
        let startX = size.width + 100
        let magnetSize = CGSize(width: 43, height: 42)
        
        let startPos = CGPoint(x: startX, y: size.height / 2)
        let newEntity = magnetEntity(imageName: "magnet", size: magnetSize, startPosition: startPos, speed: 1.5)
        
        finalizeSpawn(entity: newEntity, startPos: startPos)
    }
}

// MARK: - Cleanup System
extension gameScene {
    
    private func cleanupOffScreenEntities() {
        // Fungsi ini akan mengecek semua entity, dan MENGHAPUSNYA jika return true
        entities.removeAll { entity in
            
            // 1. Pastikan dia adalah trash atau obstacle
            guard entity is trashEntity || entity is obstacleEntity || entity is fishEntity else {
                return false
            }
            
            // 2. Cek apakah posisinya sudah jauh di luar layar kiri
            guard
                let posComp = entity.component(ofType: positionComponent.self),
                posComp.position.x < -250
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
            
            sessionTrash += 1
            hud?.incrementTrash()
            gameStateRef?.trash = sessionTrash
            
        } else if collision == physicsCategory.submarine | physicsCategory.power
        {
            let powerNode =
            bodyA == physicsCategory.power
            ? contact.bodyA.node : contact.bodyB.node
            
            soundComponent.shared.playCollectMagnetSound(scene: self)
            
            print("Power-up diambil!")
            
            guard powerNode?.name == "magnet" else { return }
            powerNode?.name = "collected"
            powerNode?.removeFromParent()
            
            self.gameStateRef?.isMagnetic = true
            
            self.playerEntity?.setMagnetSubmarineTexture(isActive: true)
            
            // 2. Buat aksi menunggu 10 detik
            let waitAction = SKAction.wait(forDuration: 10.0)
            
            let turnOffAction = SKAction.run { [weak self] in
                self?.gameStateRef?.isMagnetic = false
                
                self?.playerEntity?.setMagnetSubmarineTexture(isActive: false)
                
                if let self = self {
                    soundComponent.shared.playCollectMagnetSound(scene: self)
                }
                
                print("Efek magnet telah habis!")
            }
            
            
            let magnetSequence = SKAction.sequence([waitAction, turnOffAction])
            
            
            // 5. Jalankan dengan Key.
            // Jika pemain ambil magnet lagi di detik ke-9, timer lama akan otomatis ditimpa timer baru!
            self.run(magnetSequence, withKey: "magnet_timer")
            
        } else if collision == physicsCategory.submarine
                    | physicsCategory.obstacle
        {
            let submarinePosition =
            playerEntity?
                .component(ofType: spriteComponent.self)?.node.position
            ?? CGPoint(x: size.width * 0.2, y: size.height / 2)
            
            soundComponent.shared.obstacleHaptic()
            soundComponent.shared.playExplosionSound(scene: self)
            soundComponent.shared.stopBGM()
            
            print("GAME OVER: Menabrak rintangan!")
            
            removeAction(forKey: "entity_spawn")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.playerEntity?.component(ofType: spriteComponent.self)?.node
                    .removeFromParent()
            }
            removeAction(forKey: "magnet_spawn")
            
            playerEntity?.component(ofType: flashlightComponent.self)?
                .containerNode.removeFromParent()
            playerEntity?.component(ofType: spriteComponent.self)?.node
                .removeFromParent()
            
            saveSessionResults()
            gameStateRef?.trash = sessionTrash
            gameStateRef?.distance = CGFloat(sessionDistance)
            
            spawnExplosion(at: submarinePosition) { [weak self] in
                self?.fadeToBlackThenGameOver()
            }
        }
    }
}

// MARK: - Explosion
extension gameScene {
    func spawnExplosion(at position: CGPoint, completion: @escaping () -> Void)
    {
        let explosionSize = CGSize(width: 120, height: 120)
        let texture = SKTexture(imageNamed: "explosion")
        
        let explosionNode = SKSpriteNode(
            texture: texture,
            size: explosionSize
        )
        explosionNode.position = position
        explosionNode.zPosition = 50
        explosionNode.name = "explosion"
        explosionNode.setScale(0.3)
        addChild(explosionNode)
        
        let scaleUp = SKAction.scale(to: 1.8, duration: 0.4)
        scaleUp.timingMode = .easeOut
        
        let rotate = SKAction.rotate(byAngle: .pi / 3, duration: 0.4)
        
        let explodeAnimation = SKAction.group([scaleUp, rotate])
        
        let cleanup = SKAction.run {
            explosionNode.removeFromParent()
            completion()
        }
        
        explosionNode.run(SKAction.sequence([explodeAnimation, cleanup]))
    }
    
    func fadeToBlackThenGameOver() {
        let blackOverlay = SKSpriteNode(
            color: UIColor.black.withAlphaComponent(0.5),
            size: self.size
        )
        blackOverlay.anchorPoint = CGPoint(x: 0, y: 0)
        blackOverlay.position = .zero
        blackOverlay.zPosition = 200
        blackOverlay.alpha = 0
        blackOverlay.name = "fadeOverlay"
        addChild(blackOverlay)
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.4)
        let triggerGameOver = SKAction.run { [weak self] in
            self?.gameStateRef?.isGameOver = true
            self?.wasGameOver = true
        }
        
        blackOverlay.run(SKAction.sequence([fadeIn, triggerGameOver]))
    }
}

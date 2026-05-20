import SpriteKit

struct SubmarineItem {
    let index: Int   // 1-based, sesuai nama asset: submarine1, submarine2, …
    let price: Int   // harga dalam trash; 0 = gratis (starter)
}

class shopScene: SKScene {

    // MARK: - constants

    private let submarines: [SubmarineItem] = [
        SubmarineItem(index: 1, price: 0),
        SubmarineItem(index: 2, price: 500),
        SubmarineItem(index: 3, price: 1_200),
        SubmarineItem(index: 4, price: 5_000),
        SubmarineItem(index: 5, price: 5_000),
        SubmarineItem(index: 6, price: 15_000),
    ]

    private let kTotalTrash  = "totalTrash"
    private let kHighScore   = "highScore"
    private let kOwnedSubs   = "ownedSubmarines"
    private let kEquippedSub = "equippedSubmarine"

    private let cardColumns  = 3
    private let cardRows     = 2

    // tinggi area top bar — dipakai di grid dan preview
    private let kTopBarH: CGFloat = 64

    // MARK: - state

    private var totalTrash:      Int      = 0
    private var highScore:       Int      = 0
    private var ownedSubs:       Set<Int> = [1]
    private var equippedSub:     Int      = 1
    private var pendingSubIndex: Int?     = nil
    private var previewBaseY:    CGFloat  = 0   // titik tengah animasi bobbing

    // batas ukuran preview kiri, dihitung dari lebar panel dan tinggi konten
    private var previewMaxW: CGFloat { size.width * 0.44 * 0.62 }
    private var previewMaxH: CGFloat { (size.height - kTopBarH) * 0.46 }

    // MARK: - node references

    private var previewContainer: SKNode!
    private var previewNode: SKSpriteNode!
    private var hudView: HUDView!
    private var popupNode: SKNode?
    private var cardNodes: [Int: SKNode] = [:]

    var gameStateRef: gameState?

    // MARK: - lifecycle

    override func didMove(to view: SKView) {
        DispatchQueue.main.async { [weak self] in
            self?.gameStateRef?.currentScreen = .shop
        }

        loadPersistentData()
        buildScene()
    }

    // MARK: - persistence

    private func loadPersistentData() {
        // totalTrash dibaca dari UserDefaults yang di-set oleh homeScene
        totalTrash  = UserDefaults.standard.integer(forKey: kTotalTrash)
        highScore   = UserDefaults.standard.integer(forKey: kHighScore)

        equippedSub = UserDefaults.standard.integer(forKey: kEquippedSub)
        if equippedSub == 0 { equippedSub = 1 }

        if let saved = UserDefaults.standard.array(forKey: kOwnedSubs) as? [Int] {
            ownedSubs = Set(saved)
        }
        ownedSubs.insert(1)   // submarine pertama selalu dimiliki
        if !ownedSubs.contains(equippedSub) { equippedSub = 1 }
    }

    private func savePersistentData() {
        UserDefaults.standard.set(totalTrash, forKey: kTotalTrash)
        UserDefaults.standard.set(equippedSub, forKey: kEquippedSub)
        UserDefaults.standard.set(Array(ownedSubs), forKey: kOwnedSubs)
    }

    // MARK: - scene construction

    private func buildScene() {
        backgroundColor = .black
        buildBackground()
        buildTopBar()
        buildPreviewPanel()
        buildGrid()
        refreshPreview()
    }

    private func buildBackground() {
        let bg = SKSpriteNode(imageNamed: "backgroundShop")
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size      = size
        bg.zPosition = -10
        addChild(bg)
    }

    // MARK: top bar
    
    private func buildTopBar() {
        let barY: CGFloat = size.height - 35
        let leftMargin: CGFloat = 92

        let backButton = SKSpriteNode(imageNamed: "backShopTop")
        
        backButton.size     = CGSize(width: 80, height: 30)
        backButton.position = CGPoint(x: leftMargin, y: barY)
        backButton.name     = "backButton"
        backButton.zPosition = 20
        
        addChild(backButton)

        hudView = HUDView(sceneSize: size, mode: .homeShop)
        addChild(hudView)
        hudView.distance = highScore
        hudView.trashCount = totalTrash
    }

    // MARK: preview panel (kiri)

    private func buildPreviewPanel() {
        previewBaseY = size.height * 0.46
        
        // Fix container untuk preview bagian kiri
        previewContainer = SKNode()
        previewContainer.position  = CGPoint(x: size.width * 0.22, y: previewBaseY)
        previewContainer.zPosition = 5
        addChild(previewContainer)
        
        previewNode = SKSpriteNode(imageNamed: "submarine\(equippedSub)")
        previewNode.name = "previewSprite"
        previewContainer.addChild(previewNode)
        
        refreshPreview()

        // Animate the container
        let up   = SKAction.moveTo(y: previewBaseY + 8, duration: 1.0)
        let down = SKAction.moveTo(y: previewBaseY - 8, duration: 1.0)
        up.timingMode   = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        previewContainer.run(SKAction.repeatForever(SKAction.sequence([up, down])))
    }

    // MARK: grid (kanan)

    private func buildGrid() {
        let padTop:   CGFloat = 10
        let padBot:   CGFloat = 12
        let padRight: CGFloat = 16
        let padLeft:  CGFloat = 12
        let hSpacing: CGFloat = 10
        let vSpacing: CGFloat = 10

        let gridStartX = size.width * 0.47 + padLeft
        let gridEndX   = size.width - padRight
        let gridWidth  = gridEndX - gridStartX
        let gridTopY   = size.height - kTopBarH - padTop
        let gridHeight = size.height - kTopBarH - padTop - padBot

        let cW = (gridWidth  - hSpacing * CGFloat(cardColumns - 1)) / CGFloat(cardColumns)
        let cH = (gridHeight - vSpacing * CGFloat(cardRows    - 1)) / CGFloat(cardRows)
        let cardSize = CGSize(width: cW, height: cH)

        for (idx, sub) in submarines.enumerated() {
            let col  = idx % cardColumns
            let row  = idx / cardColumns
            let x    = gridStartX + (cW + hSpacing) * CGFloat(col) + cW / 2
            let y    = gridTopY   - ((cH + vSpacing) * CGFloat(row)) - cH / 2
            let card = buildCard(for: sub, cardSize: cardSize, at: CGPoint(x: x, y: y))
            addChild(card)
            cardNodes[sub.index] = card
        }
    }

    private func rebuildGrid() {
        cardNodes.values.forEach { $0.removeFromParent() }
        cardNodes.removeAll()
        buildGrid()
    }

    // MARK: card builder

    private func buildCard(for sub: SubmarineItem,
                           cardSize: CGSize,
                           at position: CGPoint) -> SKNode {
        let root       = SKNode()
        root.position  = position
        root.zPosition = 5
        root.name      = "card_\(sub.index)"

        let isEquipped = equippedSub == sub.index
        let isOwned    = ownedSubs.contains(sub.index)

        // pilih asset background card berdasarkan status
        let bgAsset: String
        if isEquipped {
            bgAsset = "equippedButton"
        } else if isOwned {
            bgAsset = "selectButton"
        } else {
            switch sub.price {
            case 500:    bgAsset = "button500"
            case 1_200:  bgAsset = "button1200"
            case 5_000:  bgAsset = "button5000"
            case 15_000: bgAsset = "button15000"
            default:     bgAsset = "button500"
            }
        }

        let cardBG       = SKSpriteNode(imageNamed: bgAsset)
        cardBG.size      = cardSize
        cardBG.zPosition = 0
        root.addChild(cardBG)

        let thumbTex  = SKTexture(imageNamed: "submarine\(sub.index)")
        let natSz     = thumbTex.size()
        let maxThumbW = cardSize.width  * 0.74
        let maxThumbH = cardSize.height * 0.50
        let thumb     = SKSpriteNode(texture: thumbTex)
        if natSz.width > 0 && natSz.height > 0 {
            let sc     = min(maxThumbW / natSz.width, maxThumbH / natSz.height)
            thumb.size = CGSize(width: natSz.width * sc, height: natSz.height * sc)
        } else {
            thumb.size = CGSize(width: maxThumbW * 0.85, height: maxThumbH * 0.85)
        }
        thumb.position  = CGPoint(x: 0, y: cardSize.height * 0.09)
        thumb.zPosition = 1
        root.addChild(thumb)

        return root
    }

    // MARK: - preview

    private func refreshPreview() {
        let tex = SKTexture(imageNamed: "submarine\(equippedSub)")
        previewNode.texture = tex
        
        // Reset scale to 1.0 before recalculating to ensure accurate native sizes
        previewNode.setScale(1.0)
        previewNode.size = tex.size()
        
        // Recalculate scale from the new texture so it fits perfectly inside the max bounds
        let nSz = tex.size()
        if nSz.width > 0 && nSz.height > 0 {
            let sc = min(previewMaxW / nSz.width, previewMaxH / nSz.height)
            previewNode.setScale(sc)
        }
        
        // Keep the sprite perfectly centered inside the container frame
        previewNode.position = .zero
    }

    // MARK: - popups

    private func showConfirmPopup(for sub: SubmarineItem) {
        dismissPopup()
        pendingSubIndex = sub.index

        let popup       = SKNode()
        popup.zPosition = 200
        popup.name      = "popup"

        let dim = SKShapeNode(rectOf: size)
        dim.fillColor   = SKColor(white: 0, alpha: 0.45)
        dim.strokeColor = .clear
        dim.position    = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.zPosition   = -1
        popup.addChild(dim)

        let popupW: CGFloat = 340
        let popupH: CGFloat = 260
        let bg = SKSpriteNode(imageNamed: "popUpShop")
        bg.size      = CGSize(width: popupW, height: popupH)
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = 0
        popup.addChild(bg)

        let imgTex   = SKTexture(imageNamed: "submarine\(sub.index)")
        let imgNatSz = imgTex.size()
        let popMaxW: CGFloat = 150
        let popMaxH: CGFloat = 88
        let img = SKSpriteNode(texture: imgTex)
        if imgNatSz.width > 0 && imgNatSz.height > 0 {
            let sc   = min(popMaxW / imgNatSz.width, popMaxH / imgNatSz.height)
            img.size = CGSize(width: imgNatSz.width * sc, height: imgNatSz.height * sc)
        } else {
            img.size = CGSize(width: 140, height: 80)
        }
        img.position  = CGPoint(x: size.width / 2, y: size.height / 2 + popupH * 0.22)
        img.zPosition = 1
        popup.addChild(img)

        let priceLbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        priceLbl.text                    = "BUY WITH \(formatNumber(sub.price)) TRASH"
        priceLbl.fontSize                = 18
        priceLbl.fontColor               = SKColor(red: 0.12, green: 0.25, blue: 0.50, alpha: 1)
        priceLbl.horizontalAlignmentMode = .center
        priceLbl.verticalAlignmentMode   = .center
        priceLbl.position                = CGPoint(x: size.width / 2,
                                                   y: size.height / 2 - popupH * 0.06)
        priceLbl.zPosition = 1
        popup.addChild(priceLbl)

        let confirmBtn = SKSpriteNode(imageNamed: "confirmShop")
        confirmBtn.size      = CGSize(width: 180, height: 52)
        confirmBtn.position  = CGPoint(x: size.width / 2, y: size.height / 2 - popupH * 0.28)
        confirmBtn.name      = "confirmButton"
        confirmBtn.zPosition = 1
        popup.addChild(confirmBtn)

        presentPopup(popup)
    }

    private func showInsufficientTrashPopup(for sub: SubmarineItem) {
        dismissPopup()

        let popup       = SKNode()
        popup.zPosition = 200
        popup.name      = "popup"

        let dim = SKShapeNode(rectOf: size)
        dim.fillColor   = SKColor(white: 0, alpha: 0.45)
        dim.strokeColor = .clear
        dim.position    = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.zPosition   = -1
        popup.addChild(dim)

        let popupW: CGFloat = 340
        let popupH: CGFloat = 260
        let bg = SKSpriteNode(imageNamed: "popUpShop")
        bg.size      = CGSize(width: popupW, height: popupH)
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = 0
        popup.addChild(bg)

        let imgTex   = SKTexture(imageNamed: "submarine\(sub.index)")
        let imgNatSz = imgTex.size()
        let popMaxW: CGFloat = 150
        let popMaxH: CGFloat = 88
        let img = SKSpriteNode(texture: imgTex)
        if imgNatSz.width > 0 && imgNatSz.height > 0 {
            let sc   = min(popMaxW / imgNatSz.width, popMaxH / imgNatSz.height)
            img.size = CGSize(width: imgNatSz.width * sc, height: imgNatSz.height * sc)
        } else {
            img.size = CGSize(width: 140, height: 80)
        }
        img.position  = CGPoint(x: size.width / 2, y: size.height / 2 + popupH * 0.22)
        img.zPosition = 1
        popup.addChild(img)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text                    = "TRASH NOT ENOUGH"
        label.fontSize                = 20
        label.fontColor               = SKColor(red: 0.12, green: 0.25, blue: 0.50, alpha: 1)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode   = .center
        label.position                = CGPoint(x: size.width / 2,
                                                y: size.height / 2 - popupH * 0.06)
        label.zPosition = 1
        popup.addChild(label)

        let backBtn = SKSpriteNode(imageNamed: "backShop")
        backBtn.size      = CGSize(width: 160, height: 52)
        backBtn.position  = CGPoint(x: size.width / 2, y: size.height / 2 - popupH * 0.28)
        backBtn.name      = "popupBackButton"
        backBtn.zPosition = 1
        popup.addChild(backBtn)

        presentPopup(popup)
    }

    private func presentPopup(_ popup: SKNode) {
        popup.setScale(1.0)
        addChild(popup)
        popupNode = popup
    }

    private func dismissPopup() {
        popupNode?.removeFromParent()
        popupNode       = nil
        pendingSubIndex = nil
    }

    // MARK: - purchase / select logic

    private func purchaseSubmarine(subIndex: Int) {
        guard let sub = submarines.first(where: { $0.index == subIndex }) else { return }
        guard totalTrash >= sub.price else { return }

        totalTrash -= sub.price
        ownedSubs.insert(subIndex)
        equippedSub = subIndex
        savePersistentData()

        hudView.trashCount = totalTrash
        rebuildGrid()
        refreshPreview()
        dismissPopup()
    }

    private func selectSubmarine(subIndex: Int) {
        guard ownedSubs.contains(subIndex) else { return }
        equippedSub = subIndex
        savePersistentData()
        rebuildGrid()
        refreshPreview()
        dismissPopup()
    }

    // MARK: - touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc    = touch.location(in: self)
        let tapped = nodes(at: loc)

        for node in tapped {
            switch node.name {
            case "backButton":
                dismissPopup()
                goHome()
                return

            case "confirmButton":
                if let idx = pendingSubIndex {
                    purchaseSubmarine(subIndex: idx)
                }
                return

            case "popupBackButton":
                dismissPopup()
                return

            default:
                break
            }

            // card tap hanya diproses kalau tidak ada popup yang terbuka
            if popupNode == nil {
                var n: SKNode? = node
                while let current = n {
                    if let name = current.name,
                       name.hasPrefix("card_"),
                       let idxStr = name.split(separator: "_").last,
                       let subIndex = Int(idxStr) {
                        handleCardTap(subIndex: subIndex)
                        return
                    }
                    n = current.parent
                }
            }
        }
    }

    private func handleCardTap(subIndex: Int) {
        guard let sub = submarines.first(where: { $0.index == subIndex }) else { return }

        let isOwned    = ownedSubs.contains(subIndex)
        let isEquipped = equippedSub == subIndex

        if isEquipped {
            return   // sudah dipakai, tidak perlu apa-apa
        } else if isOwned {
            selectSubmarine(subIndex: subIndex)   // sudah punya, langsung pakai
        } else if totalTrash >= sub.price {
            showConfirmPopup(for: sub)            // cukup trash, tanya konfirmasi
        } else {
            showInsufficientTrashPopup(for: sub)  // trash kurang
        }
    }

    // MARK: - navigation

    private func goHome() {
        gameStateRef?.currentScreen = .home
        gameStateRef?.shouldReturnHome = false

        let scene = homeScene(size: SceneSizeProvider.current(for: view))
        scene.scaleMode = .aspectFill
        scene.gameStateRef = gameStateRef
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
    }

    // MARK: - helpers

    // format angka dengan titik sebagai pemisah ribuan, misal 15000 → "15.000"
    private func formatNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle       = .decimal
        formatter.groupingSeparator = "."
        formatter.groupingSize      = 3
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

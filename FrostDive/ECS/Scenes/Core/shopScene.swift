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

    private var previewNode:     SKSpriteNode!
    private var trashCountLabel: SKLabelNode!
    private var distanceLabel:   SKLabelNode!
    private var popupNode:       SKNode?
    private var cardNodes:       [Int: SKNode] = [:]

    // MARK: - lifecycle

    override func didMove(to view: SKView) {
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
        let barY: CGFloat = size.height - 22

        // back button: icon + label "Back" dalam satu group
        let backGroup = SKNode()
        backGroup.name      = "backButton"
        backGroup.zPosition = 20
        backGroup.position  = CGPoint(x: 82, y: barY)
        addChild(backGroup)

        let backIcon = SKSpriteNode(imageNamed: "backIcon")
        backIcon.size     = CGSize(width: 24, height: 24)
        backIcon.position = .zero
        backIcon.name     = "backButton"
        backGroup.addChild(backIcon)

        let backLbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        backLbl.text                    = "Back"
        backLbl.fontSize                = 16
        backLbl.fontColor               = .white
        backLbl.horizontalAlignmentMode = .left
        backLbl.verticalAlignmentMode   = .center
        backLbl.position                = CGPoint(x: 16, y: 0)
        backLbl.name                    = "backButton"
        backGroup.addChild(backLbl)

        // distance hud
        let distGroup = SKNode()
        distGroup.zPosition = 20
        distGroup.position  = CGPoint(x: size.width * 0.645, y: barY)
        addChild(distGroup)

        let distIcon = SKSpriteNode(imageNamed: "distanceIcon")
        distIcon.size     = CGSize(width: 26, height: 26)
        distIcon.position = .zero
        distGroup.addChild(distIcon)

        let distLbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        distLbl.text                    = "\(highScore)m"
        distLbl.fontSize                = 18
        distLbl.fontColor               = .white
        distLbl.horizontalAlignmentMode = .left
        distLbl.verticalAlignmentMode   = .center
        distLbl.position                = CGPoint(x: 18, y: 0)
        distGroup.addChild(distLbl)
        distanceLabel = distLbl

        // trash hud
        let trashGroup = SKNode()
        trashGroup.zPosition = 20
        trashGroup.position  = CGPoint(x: size.width * 0.82, y: barY)
        addChild(trashGroup)

        let trashIcon = SKSpriteNode(imageNamed: "trashIcon")
        trashIcon.size     = CGSize(width: 26, height: 26)
        trashIcon.position = .zero
        trashGroup.addChild(trashIcon)

        let trashLbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        trashLbl.text                    = "\(totalTrash)"
        trashLbl.fontSize                = 18
        trashLbl.fontColor               = .white
        trashLbl.horizontalAlignmentMode = .left
        trashLbl.verticalAlignmentMode   = .center
        trashLbl.position                = CGPoint(x: 18, y: 0)
        trashGroup.addChild(trashLbl)
        trashCountLabel = trashLbl
    }

    // MARK: preview panel (kiri)

    private func buildPreviewPanel() {
        let preview = SKSpriteNode(imageNamed: "submarine\(equippedSub)")
        let pNative = preview.size
        if pNative.width > 0 && pNative.height > 0 {
            let sc = min(previewMaxW / pNative.width, previewMaxH / pNative.height)
            preview.setScale(sc)
        }
        previewBaseY      = size.height * 0.46
        preview.position  = CGPoint(x: size.width * 0.22, y: previewBaseY)
        preview.zPosition = 5
        preview.name      = "previewSprite"
        addChild(preview)
        previewNode = preview
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

        // preload texture dulu sebelum baca size()-nya
        // supaya aspect ratio tidak berubah dan gambar tidak gepeng
        let thumbTex  = SKTexture(imageNamed: "submarine\(sub.index)")
        SKTexture.preload([thumbTex]) { }
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
        // recalculate scale dari texture baru supaya ukuran tetap konsisten
        let nSz = tex.size()
        if nSz.width > 0 && nSz.height > 0 {
            let sc = min(previewMaxW / nSz.width, previewMaxH / nSz.height)
            previewNode.setScale(sc)
        }
        // reset posisi ke base sebelum mulai animasi — cegah drift ke atas
        previewNode.removeAllActions()
        previewNode.position = CGPoint(x: size.width * 0.22, y: previewBaseY)

        let up   = SKAction.moveTo(y: previewBaseY + 8, duration: 1.0)
        let down = SKAction.moveTo(y: previewBaseY - 8, duration: 1.0)
        up.timingMode   = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        previewNode.run(SKAction.repeatForever(SKAction.sequence([up, down])))
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

        // preload texture submarine supaya size() akurat dan gambar tidak gepeng
        let imgTex   = SKTexture(imageNamed: "submarine\(sub.index)")
        SKTexture.preload([imgTex]) { }
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

        // preload texture submarine supaya size() akurat dan gambar tidak gepeng
        let imgTex   = SKTexture(imageNamed: "submarine\(sub.index)")
        SKTexture.preload([imgTex]) { }
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
        popup.setScale(0.1)
        addChild(popup)
        popupNode = popup
        popup.run(SKAction.scale(to: 1.0, duration: 0.22))
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

        trashCountLabel.text = "\(totalTrash)"
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
        let scene = HomeScene(size: size)
        scene.scaleMode = .aspectFill
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

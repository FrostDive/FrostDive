//
//  movementSystem.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 15/05/26.
//

import GameplayKit

class MovementSystem: GKComponentSystem<movementComponent> {
    var sceneSize: CGSize
    let totalBackgrounds: CGFloat = 15
    
    var isMagnetActive: Bool = false
    var submarinePosition: CGPoint?
    var speedMultiplier: CGFloat = 1.0
    
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init(componentClass: movementComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        for component in components {
            guard let entity = component.entity,
                  let posComp = entity.component(ofType: positionComponent.self)
            else { continue }
            
            posComp.position.x -= (component.speed * speedMultiplier)
            
            if entity is trashEntity {
                
                let waveSpeed: CGFloat = 1.2
                let waveHeight: CGFloat = 0.4
                
                let wave =
                cos(CGFloat(CACurrentMediaTime()) * waveSpeed
                    + component.bobbingOffset)
                * waveHeight
                
                posComp.position.y += wave
            }
        
            if entity is backgroundEntity {
                if posComp.position.x <= -sceneSize.width {
                    // Pindahkan ke paling belakang dari rangkaian 15 gambar
                    // Rumus: posisi sekarang + (total gambar * lebar gambar)
                    posComp.position.x += sceneSize.width * totalBackgrounds
                }
            }
            
            var isBeingPulled = false
            
            if isMagnetActive, entity is trashEntity, let target = submarinePosition {
                // Hitung jarak x dan y antara sampah dan kapal selam
                let dx = target.x - posComp.position.x
                let dy = target.y - posComp.position.y
                
                // Hitung total jarak miring (Pythagoras)
                let distance = sqrt(dx * dx + dy * dy)
                
                // Jika jaraknya masih lebih dari 5 pixel, tarik perlahan
                if distance < 300.0 {
                    isBeingPulled = true
                    let magnetPullSpeed: CGFloat = 8.0 // Semakin besar, sedotannya makin kencang
                    
                    // Rumus vektor: Arahkan ke target lalu kalikan kecepatan tarik
                    posComp.position.x += (dx / distance) * magnetPullSpeed
                    posComp.position.y += (dy / distance) * magnetPullSpeed
                }
            }
            
            if !isBeingPulled, let animComp = entity.component(ofType: animationComponent.self) {
                
                // Ambil titik Y awal saat objek pertama kali muncul
                if !animComp.isInitialized {
                    animComp.startY = posComp.position.y
                    // Beri nilai acak pada timePassed agar setiap objek mengambang tidak serentak (sync)
                    animComp.timePassed = Double.random(in: 0...Double.pi * 2)
                    animComp.isInitialized = true
                }
                
                // Majukan waktu
                animComp.timePassed += seconds * Double(animComp.animationSpeed)
                
                // Hitung posisi Y baru menggunakan Gelombang Sinus
                // sin() menghasilkan kurva mulus dari -1 hingga 1.
                let waveOffset = CGFloat(sin(animComp.timePassed)) * animComp.animationDistance
                posComp.position.y = animComp.startY + waveOffset
            }
        }
    }
}

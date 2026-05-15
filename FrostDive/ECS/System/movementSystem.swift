//
//  movementSystem.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 15/05/26.
//


import GameplayKit

class MovementSystem: GKComponentSystem<movementComponent> {
    var sceneSize: CGSize
    let totalBackgrounds: CGFloat = 15 // Sesuai aset background
    
    var isMagnetActive: Bool = false
    var submarinePosition: CGPoint?
    
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init(componentClass: movementComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        for component in components {
            guard let entity = component.entity,
                  let posComp = entity.component(ofType: positionComponent.self) else { continue }
            
            // Gerakkan ke kiri
            posComp.position.x -= component.speed
            
            // Logika Looping untuk 15 Background
            if entity is backgroundEntity {
                if posComp.position.x <= -sceneSize.width {
                    // Pindahkan ke paling belakang dari rangkaian 15 gambar
                    // Rumus: posisi sekarang + (total gambar * lebar gambar)
                    posComp.position.x += sceneSize.width * totalBackgrounds
                }
            }
            
            if isMagnetActive, entity is trashEntity, let target = submarinePosition {
                // Hitung jarak x dan y antara sampah dan kapal selam
                let dx = target.x - posComp.position.x
                let dy = target.y - posComp.position.y
                
                // Hitung total jarak miring (Pythagoras)
                let distance = sqrt(dx * dx + dy * dy)
                
                // Jika jaraknya masih lebih dari 5 pixel, tarik perlahan
                if distance > 5.0 {
                    let magnetPullSpeed: CGFloat = 8.0 // Semakin besar, sedotannya makin kencang
                    
                    // Rumus vektor: Arahkan ke target lalu kalikan kecepatan tarik
                    posComp.position.x += (dx / distance) * magnetPullSpeed
                    posComp.position.y += (dy / distance) * magnetPullSpeed
                }
            }
        }
    }
}


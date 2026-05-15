//
//  movementSystem.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 15/05/26.
//


import GameplayKit

class MovementSystem: GKComponentSystem<movementComponent> {
    var sceneSize: CGSize
    let totalBackgrounds: CGFloat = 15 // Sesuai asetmu
    
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
        }
    }
}

//
//  soundComponent.swift
//  FrostDive
//
//  Created by Steffany Florence on 13/05/26.
//

import AVFAudio
import GameplayKit
import SpriteKit
import UIKit

class soundComponent: GKComponent {
    static let shared = soundComponent()

    // MARK: - Background Music
    private var bgmNode: SKAudioNode?
    func playBGM(scene: SKScene) {
        if bgmNode != nil { return }

        let bgm = SKAudioNode(fileNamed: "bgm.mp3")

        bgm.autoplayLooped = true
        bgm.name = "bgm"

        scene.addChild(bgm)

        self.bgmNode = bgm
    }

    func stopBGM() {

        bgmNode?.removeFromParent()
        bgmNode = nil
    }

    // MARK: - Sound Effects
    func playCollectSound(scene: SKScene) {
        print("PLAY collect SOUND")

        let action = SKAction.playSoundFileNamed(
            "collect.wav",
            waitForCompletion: false
        )

        scene.run(action)
    }

    func playExplosionSound(scene: SKScene) {
        print("PLAY EXPLOSION SOUND")

        let action = SKAction.playSoundFileNamed(
            "explosion.wav",
            waitForCompletion: false
        )

        scene.run(action)
    }

    // MARK: - Haptic
    func obstacleHaptic() {

        DispatchQueue.main.async {

            let generator = UIImpactFeedbackGenerator(style: .heavy)

            generator.prepare()
            generator.impactOccurred(intensity: 1.0)
        }
    }

    func setupAudioSession() {

        do {

            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default
            )

            try AVAudioSession.sharedInstance().setActive(true)

            print("AUDIO SESSION READY")

        } catch {

            print("AUDIO SESSION ERROR")
        }
    }
}

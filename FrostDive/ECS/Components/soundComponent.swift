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

    // MARK: - Background Music Game
    private var bgmNode: SKAudioNode?
    func playBGM(scene: SKScene) {
        stopHomeBGM()

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

    // MARK: - Pause / Resume Music
    func pauseMusic() {
        bgmNode?.run(SKAction.pause())
    }

    func resumeMusic() {
        bgmNode?.run(SKAction.play())
    }

    // MARK: - Background Music Home & Shop
    private var homeBgmPlayer: AVAudioPlayer?
    func playHomeBGM() {

        stopBGM()

        // kalau sudah play jangan ulang dari awal
        if homeBgmPlayer?.isPlaying == true {
            return
        }

        guard
            let url = Bundle.main.url(
                forResource: "homeBgm",
                withExtension: "mp3"
            )
        else {
            print("homeBgm.mp3 NOT FOUND")
            return
        }

        do {

            homeBgmPlayer = try AVAudioPlayer(contentsOf: url)

            homeBgmPlayer?.numberOfLoops = -1
            homeBgmPlayer?.prepareToPlay()
            homeBgmPlayer?.play()

        } catch {

            print("FAILED PLAY HOME BGM")
        }
    }

    func stopHomeBGM() {

        homeBgmPlayer?.stop()
        homeBgmPlayer = nil
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

    func playCollectMagnetSound(scene: SKScene) {
        print("PLAY collect magnet SOUND")

        let action = SKAction.playSoundFileNamed(
            "powerUp.wav",
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

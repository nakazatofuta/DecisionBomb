//
//  BombViewController.swift
//  DecisionBomb
//
//  Created by 中里 楓太 on 2024/05/18.
//

import AudioToolbox
import AVFoundation
import UIKit

class BombViewController: UIViewController {
    @IBOutlet var buttonImage: [UIImageView]!
    @IBOutlet weak var safeLabel: UILabel!

    var bombButtonImage: UIImageView?
    var safeSound: AVAudioPlayer!
    var bombSound: AVAudioPlayer!
    var pushSound: AVAudioPlayer!

    var vibrationTimer: Timer?
    var shortVibrationCount = 0
    var longVibrationCount = 0
    var shortCurrentCount = 0
    var longCurrentCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // 爆弾をランダムで決定
        guard let bomb = buttonImage.randomElement() else {
            return
        }
        bombButtonImage = bomb
        shortVibrationCount = bomb.tag / 10
        longVibrationCount = bomb.tag % 10
        print("行:\(shortVibrationCount),列:\(longVibrationCount)")
        startVibration()
        safeSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "safe", ofType: "mp3")!))
        bombSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "bomb", ofType: "mp3")!))
        pushSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "push", ofType: "mp3")!))

        // タップ機能を設定
        for buttonImage in buttonImage {
            if buttonImage.tag == bombButtonImage?.tag {}
            buttonImage.isUserInteractionEnabled = true
            buttonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        }
        safeLabel.alpha = 0
    }

    func startVibration() {
        // タイマーを設定し、0.6秒ごとにvibrateメソッドを呼び出す
        vibrationTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(vibrate), userInfo: nil, repeats: true)
    }

    @objc func vibrate() {
        if shortCurrentCount < shortVibrationCount {
            // 短いバイブレーションを実行
            AudioServicesPlaySystemSound(1520)
            shortCurrentCount += 1
        } else if longCurrentCount < longVibrationCount {
            // 長いバイブレーションを実行
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            longCurrentCount += 1
        } else {
            // 指定した回数に達したらタイマーを停止
            vibrationTimer?.invalidate()
            vibrationTimer = nil
        }
    }

    deinit {
        // ViewControllerが解放されるときにタイマーを無効にする
        vibrationTimer?.invalidate()
    }

    func playSafeSound() {
        safeSound.stop()
        safeSound.currentTime = 0
        safeSound.play()
    }

    func playBombSound() {
        bombSound.stop()
        bombSound.currentTime = 0
        bombSound.play()
    }

    func playPushSound() {
        pushSound.stop()
        pushSound.currentTime = 0
        pushSound.play()
    }

    @objc
    func tapped(_ sender: UITapGestureRecognizer) {
        guard let tappedButtonImage: UIImageView = sender.view as? UIImageView else {
            return
        }
        playPushSound()
        tappedButtonImage.image = UIImage(named: "pushButtonOff")
        tappedButtonImage.isUserInteractionEnabled = false

        let randomWaitTime = Double.random(in: 0.0 ... 2.0)
        view.isUserInteractionEnabled = false
        if tappedButtonImage.tag == bombButtonImage?.tag {
            DispatchQueue.main.asyncAfter(deadline: .now() + randomWaitTime) {
                self.playBombSound()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + randomWaitTime) {
                self.playSafeSound()
            }
            UIView.animate(withDuration: 0.8, delay: randomWaitTime, options: .curveEaseIn) {
                self.safeLabel.alpha = 1

            } completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn) {
                    self.safeLabel.alpha = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.view.isUserInteractionEnabled = true
                }
            }
        }
    }
}

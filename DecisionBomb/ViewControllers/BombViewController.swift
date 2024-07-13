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
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var explosionImageView: UIImageView!
    @IBOutlet weak var restartButton: UIButton!

    var bombButtonImage: UIImageView?
    var safeSound: AVAudioPlayer!
    var bombSound: AVAudioPlayer!
    var pushSound: AVAudioPlayer!
    var explosionImageArray: [UIImage] = []

    var vibrationTimer: Timer?
    var shortVibrationCount = 0
    var longVibrationCount = 0
    var shortCurrentCount = 0
    var longCurrentCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        restartButton.layer.cornerRadius = 16

        while let explosionImage = UIImage(named: "explosion\(explosionImageArray.count + 1)") {
            explosionImageArray.append(explosionImage)
        }
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
        resultLabel.alpha = 0
        restartButton.alpha = 0
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
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.playBombSound()
                // アニメーションの適用
                self.explosionImageView.animationImages = self.explosionImageArray
                // 1.2秒間隔
                self.explosionImageView.animationDuration = 1.2
                // 1回繰り返し
                self.explosionImageView.animationRepeatCount = 1
                // アニメーションを開始
                self.explosionImageView.startAnimating()
                self.explosionImageView.image = UIImage(named: "explosion10")
            }
            UIView.animate(withDuration: 0.8, delay: randomWaitTime, options: .curveEaseIn) {
                self.resultLabel.text = "OUT"
                self.resultLabel.textColor = UIColor.black
                self.resultLabel.alpha = 1
                self.restartButton.alpha = 1
            } completion: { _ in
                self.view.isUserInteractionEnabled = true
                // View内のすべてのサブビューに対して処理を行う
                for subview in self.view.subviews {
                    subview.isUserInteractionEnabled = false
                    // サブビューがUIButtonであり、かつ特定のボタンでない場合
                    if let button = subview as? UIButton, button == self.restartButton {
                        // isUserInteractionEnabledプロパティをfalseに設定する
                        subview.isUserInteractionEnabled = true
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + randomWaitTime) {
                self.playSafeSound()
            }
            UIView.animate(withDuration: 0.8, delay: randomWaitTime, options: .curveEaseIn) {
                self.resultLabel.alpha = 1

            } completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn) {
                    self.resultLabel.alpha = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.view.isUserInteractionEnabled = true
                }
            }
        }
    }

    @IBAction func didTapRestartButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

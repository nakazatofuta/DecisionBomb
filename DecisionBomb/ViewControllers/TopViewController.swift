//
//  TopViewController.swift
//  DecisionBomb
//
//  Created by 中里 楓太 on 2024/05/12.
//

import AVFoundation
import UIKit

class TopViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var usageButton: UIButton!

    var startSound: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackBarButton()
        startButton.layer.cornerRadius = 16
        usageButton.layer.cornerRadius = 16
        startSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "start", ofType: "mp3")!))
    }

    func setBackBarButton() {
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
    }

    func playStartSound() {
        startSound.stop()
        startSound.currentTime = 0
        startSound.play()
    }

    @IBAction func didTapStartButton(_ sender: Any) {
        playStartSound()
        let storyboard = UIStoryboard(name: "BombViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "BombViewController")
        // 遷移
        present(viewController, animated: true)
    }

    @IBAction func didTapUsageButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "UsageViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "UsageViewController")
        navigationController?.pushViewController(viewController, animated: true)
    }
}

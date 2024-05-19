//
//  BombViewController.swift
//  DecisionBomb
//
//  Created by 中里 楓太 on 2024/05/18.
//

import UIKit

class BombViewController: UIViewController {
    @IBOutlet var buttonImage: [UIImageView]!
    @IBOutlet weak var safeLabel: UILabel!

    var bombButtonImage: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // 爆弾をランダムで決定
        bombButtonImage = buttonImage.randomElement()

        // タップ機能を設定
        for buttonImage in buttonImage {
            if buttonImage.tag == bombButtonImage?.tag {}
            buttonImage.isUserInteractionEnabled = true
            buttonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        }
        safeLabel.alpha = 0
    }

    @objc
    func tapped(_ sender: UITapGestureRecognizer) {
        guard let tappedButtonImage: UIImageView = sender.view as? UIImageView else {
            return
        }
        tappedButtonImage.image = UIImage(named: "pushButtonOff")
        tappedButtonImage.isUserInteractionEnabled = false

        if tappedButtonImage.tag == bombButtonImage?.tag {
            // アウト
            print("Bomb!!")
        } else {
            UIView.animate(withDuration: 0.8, delay: Double.random(in: 0.0 ... 2.0), options: .curveEaseIn) {
                self.safeLabel.alpha = 1
            } completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn) {
                    self.safeLabel.alpha = 0
                }
            }
        }
    }
}

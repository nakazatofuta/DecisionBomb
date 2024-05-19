//
//  UsageViewController.swift
//  DecisionBomb
//
//  Created by 中里 楓太 on 2024/05/18.
//

import CoreMotion
import UIKit

class UsageViewController: UIViewController {
    @IBOutlet weak var secretTitleLabel: UILabel!
    @IBOutlet weak var secretTextView: UITextView!

    let motionSensor = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        getAccelerometer()
    }

    func getAccelerometer() {
        // swiftlint:disable all
        motionSensor.accelerometerUpdateInterval = 0.2
        motionSensor.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {
            accelerometerData, _ in
            let x = accelerometerData!.acceleration.x
            let y = accelerometerData!.acceleration.y
            let z = accelerometerData!.acceleration.z
            let synthetic = (x * x) + (y * y) + (z * z)

            if synthetic >= 15 {
                self.secretTitleLabel.isHidden = !self.secretTitleLabel.isHidden
                self.secretTextView.isHidden = !self.secretTextView.isHidden
            }
        })
        // swiftlint:enable all
    }
}

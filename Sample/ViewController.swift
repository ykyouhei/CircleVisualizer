//
//  ViewController.swift
//  Sample
//
//  Created by 山口　恭兵 on 2017/12/17.
//  Copyright © 2017年 kyo__hei. All rights reserved.
//

import UIKit
import CircleVisualizer

class ViewController: UIViewController {
    
    @IBOutlet weak var circle: CircleVisualizer!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func didTapStart(_ sender: UIButton) {
        func set(value: CGFloat, potision: Int) {
            guard potision < self.circle.numberOfLines else {
                startButton.isEnabled = true
                resetButton.isEnabled = true
                return
            }
            
            let duration = TimeInterval(0.3)
            
            self.circle.set(value: value, at: potision, animated: true, duration: duration)
            self.circle.set(color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), at: potision, animated: true, duration: duration)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                set(value: value, potision: potision+1)
            }
        }
        
        startButton.isEnabled = false
        resetButton.isEnabled = false
        
        set(value: 1.0, potision: 0)
    }
    
    @IBAction func didTapReset(_ sender: UIButton) {
        reset()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reset()
    }
    
    private func reset() {
        let duration = TimeInterval(0.3)
        let defaultValue = CGFloat(0.5)

        self.circle.performBatchUpdates({
            (0..<self.circle.numberOfLines).forEach {
                self.circle.set(color: #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), at: $0, animated: true, duration: duration)
                self.circle.set(value: defaultValue, at: $0, animated: true, duration: duration)
            }
        }, completion: {
            print("--completion--")
        })
    }

}


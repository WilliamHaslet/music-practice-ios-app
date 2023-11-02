//
//  ScalesPracticeViewController.swift
//  Music Practice
//
//  Created by William Haslet on 12/14/22.
//

import UIKit

class ScalesPracticeViewController: UIViewController {
    @IBOutlet var scaleText: UILabel!
    
    let scales = ["A", "A♭", "B", "B♭", "C", "D", "D♭", "E", "E♭", "F", "F♯", "G"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let current = defaults.integer(forKey: "CurrentScale")
        scaleText.text = scales[current]
    }
    
    @IBAction func newScaleButton() {
        newScale()
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            newScale()
        }
    }
    
    private func newScale() {
        let defaults = UserDefaults.standard
        let current = defaults.integer(forKey: "CurrentScale")
        
        var rand = Int.random(in: 0..<12)
        if (rand == current) {
            rand += 1
            if (rand >= 12)
            {
                rand = 0
            }
        }
        
        scaleText.text = scales[rand]
        
        defaults.set(rand, forKey: "CurrentScale")
    }
}

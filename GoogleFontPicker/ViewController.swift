//
//  ViewController.swift
//  GoogleFontPicker
//
//  Created by Ting-Yang Chen on 11/17/18.
//  Copyright © 2018 Ting Yang Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI elements
    @IBOutlet weak var startButton: UIButton!

    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.startButton.setTitle(NSLocalizedString("main_fontpicker", comment: ""), for: .normal)
        
    }

    // MARK: - IBActions
    @IBAction func startButtonPressed(_ sender: Any) {
        // Already connected via storyboard.
    }
    
}


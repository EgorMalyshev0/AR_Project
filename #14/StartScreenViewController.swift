//
//  ViewController.swift
//  #14
//
//  Created by Egor Malyshev on 03.03.2021.
//

import UIKit

class StartScreenViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.cornerRadius = 4
    }

    @IBAction func startGame(_ sender: Any) {
        performSegue(withIdentifier: "showGameScreen", sender: sender)
    }
    
}


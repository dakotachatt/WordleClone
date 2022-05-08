//
//  MainViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-04-01.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = K.applicationTitle
        
        //Displays title text letter by letter
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.125 * charIndex, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.goToGameSegue, sender: self)
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
}

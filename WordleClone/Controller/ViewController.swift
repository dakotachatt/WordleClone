//
//  ViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-03-25.
//

import UIKit

class ViewController: UIViewController {
    
    let testWord : [String] = ["P", "I", "D", "G", "E"]
    var guessNum = 1
    var testWordArray : [String] = []
    var userGuess : [String] = []
    
    @IBOutlet var guess1TextFields: [UITextField]!
    @IBOutlet var guess2TextFields: [UITextField]!
    @IBOutlet var guess3TextFields: [UITextField]!
    @IBOutlet var guess4TextFields: [UITextField]!
    @IBOutlet var guess5TextFields: [UITextField]!
    @IBOutlet var guess6TextFields: [UITextField]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...4 {
            self.guess1TextFields[i].delegate = self
            self.guess2TextFields[i].delegate = self
            self.guess3TextFields[i].delegate = self
            self.guess4TextFields[i].delegate = self
            self.guess5TextFields[i].delegate = self
            self.guess6TextFields[i].delegate = self
        }
    }
    
    
    func checkAnswer() {
        for i in 0...4 {
            userGuess.append(guess1TextFields[i].text!)
        }
        
        if(guessNum == 1) {
            for i in 0...4 {
               var presentInWord = false
                
                if(userGuess[i] == testWord[i]) {
                    guess1TextFields[i].backgroundColor = UIColor.green
                } else {
                    for j in 0...4 {
                        if(i != j) {
                            if(userGuess[i] == testWord[j]) {
                                guess1TextFields[i].backgroundColor = UIColor.yellow
                                presentInWord = true
                            }
                        }
                    }
                    
                    if(!presentInWord) {
                        guess1TextFields[i].backgroundColor = UIColor.gray
                    }
                }
            }
        }
    }
}

//MARK: - Keyboard dismissing methods
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        checkAnswer()
        
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 1
    }
}

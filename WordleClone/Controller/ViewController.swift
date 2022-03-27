//
//  ViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-03-25.
//

import UIKit

class ViewController: UIViewController {
    
    let wordDatabase = ["which", "there", "their", "about", "would", "these", "other", "could", "money", "years", "place", "sound", "great", "every", "music"]
    var testWord : [String] = ["", "", "", "", ""]
    var guessNum = 1
    var currentGuessTextFieldCollection : [UITextField] = []
    var userGuess : [String] = ["", "", "", "", ""]
    
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
        
        //Generates random number from word database to use for current test word
        var testWordNum = Int.random(in: 0..<wordDatabase.count)
        
        //Converts test word string into array of single letters
        let testWordString = wordDatabase[testWordNum]
        for i in 0...4 {
            testWord[i] = testWordString[i..<(i+1)].uppercased()
        }
        
        print(testWord)
        
        currentGuessTextFieldCollection = guess1TextFields
        guess1TextFields[0].becomeFirstResponder()
    }
    
    func checkAnswer() {
        for i in 0...4 {
           var presentInWord = false
            
            if(userGuess[i] == testWord[i]) {
                currentGuessTextFieldCollection[i].backgroundColor = UIColor.green
            } else {
                for j in 0...4 {
                    if(i != j) {
                        if(userGuess[i] == testWord[j]) {
                            currentGuessTextFieldCollection[i].backgroundColor = UIColor.yellow
                            presentInWord = true
                        }
                    }
                }
                
                if(!presentInWord) {
                    currentGuessTextFieldCollection[i].backgroundColor = UIColor.gray
                }
            }
        }
        
        //Used for startNextGuess() to determine which line of textFields to enable
        guessNum += 1
        startNextGuess()
    }
    
    func startNextGuess() {
        print("Should start next guess")
        switch(guessNum) {
        case 2:
            for i in 0...4 {
                guess1TextFields[i].isEnabled = false
                guess2TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess2TextFields
                guess2TextFields[0].becomeFirstResponder()
            }
            break
        case 3:
            for i in 0...4 {
                guess2TextFields[i].isEnabled = false
                guess3TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess3TextFields
                guess3TextFields[0].becomeFirstResponder()
            }
            break
        case 4:
            for i in 0...4 {
                guess3TextFields[i].isEnabled = false
                guess4TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess4TextFields
                guess4TextFields[0].becomeFirstResponder()
            }
            break
        case 5:
            for i in 0...4 {
                guess4TextFields[i].isEnabled = false
                guess5TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess5TextFields
                guess5TextFields[0].becomeFirstResponder()
            }
            break
        case 6:
            for i in 0...4 {
                guess5TextFields[i].isEnabled = false
                guess6TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess6TextFields
                guess6TextFields[0].becomeFirstResponder()
            }
            break
        default:
            break
        }
    }
    
    //Auto select next text field after user types a letter
    @IBAction func letterChanged(_ sender: UITextField) {
        if(sender.text != "") {
            let currentTextFieldTag = sender.tag
            
            //Formula below ensures when tag is > length of word, resulting number is still between 0 - 4
            print((sender.tag - (5 * (guessNum - 1))))
            userGuess[(sender.tag - (5 * (guessNum - 1)))] = sender.text!
            
            if let nextTextField = self.view.viewWithTag(currentTextFieldTag + 1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        }
    }
    
}

//MARK: - Keyboard dismissing methods
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkAnswer()
        print(guessNum)
        print(userGuess)
        return false
    }
    
    //Ensures each text field can only have a single character
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 1
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

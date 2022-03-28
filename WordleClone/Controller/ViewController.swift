//
//  ViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-03-25.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var testWordArray : [Word] = []
    var testWord : [String] = ["", "", "", "", ""]
    var guessNum = 1
    var currentGuessTextFieldCollection : [UITextField] = []
    var userGuess : [String] = ["", "", "", "", ""]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        
        loadTestWords()
        if(testWordArray.isEmpty) {
            print("Initial Data Loaded")
            loadWordData()
        }
        
        if(testWordArray.count > 0) {
            let randomNum = Int.random(in: 0..<testWordArray.count)
            let testWordString = testWordArray[randomNum].wordText
            for i in 0...4 {
                testWord[i] = (testWordString?[i..<(i+1)].uppercased())!
            }
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
    
    func loadWordData() {
        var words = [String]()
        var wordNum = 1
        
        if let wordListURL = Bundle.main.url(forResource: "wordList", withExtension: "rtf") {
            if let wordList = try? String(contentsOf: wordListURL) {
                words = wordList.components(separatedBy: "\n")
            }
        }
        
        if(words.count > 0) {
            for i in 0..<words.count {
                let word = Word(context: self.context)
                word.wordText = words[i]
                word.guessed = false
                word.wordNumID = Int32(wordNum)
                wordNum += 1
                print(word.wordText!)
            }
        }

        saveWords()
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveWords() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func loadTestWords(with request: NSFetchRequest<Word> = Word.fetchRequest()) {
        do {
            testWordArray = try context.fetch(request)
            print("Array loaded")
        } catch {
            print("Error fetching category list: \(error)")
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

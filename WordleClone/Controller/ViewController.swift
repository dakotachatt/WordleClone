//
//  ViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-03-25.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var testWord : Word? = nil
    var testWordArray : [String] = ["", "", "", "", ""]
    var userGuess : [String] = ["", "", "", "", ""]
    var currentGuessTextFieldCollection : [UITextField] = []
    var guessNum = 1
    
    let defaults = UserDefaults.standard

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Text Field Outlets
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
        
        //Determines if user has already initially run app on device, and if not, to populate the word list
        let isWordListLoaded = defaults.bool(forKey: "WordListLoaded")
        if(!isWordListLoaded) {
            print("Initial Data Loaded")
            loadWordData()
            defaults.set(true, forKey: "WordListLoaded")
        }
        
        loadTestWord()
        
        print(testWordArray)
        
        currentGuessTextFieldCollection = guess1TextFields
        guess1TextFields[0].becomeFirstResponder()
    }
    
    //MARK: - Gameplay related functions
    func checkAnswer() {
        
        
        for i in 0...4 {
           var presentInWord = false
            
            if(userGuess[i] == testWordArray[i]) {
                currentGuessTextFieldCollection[i].backgroundColor = UIColor.green
            } else {
                for j in 0...4 {
                    if(i != j) {
                        if(userGuess[i] == testWordArray[j]) {
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
        
        //Used to track whether all letters in a given guess are correct or not - ends game if true after all letters looped through
        var correctLetterCount = 0
        
        for i in 0...4 {
            if(currentGuessTextFieldCollection[i].backgroundColor == UIColor.green) {
                correctLetterCount += 1
            }
        }
        
        //Used for startNextGuess() to determine which line of textFields to enable
        if(correctLetterCount != 5) {
            guessNum += 1
            
            if(guessNum <= 6) {
                startNextGuess()
            } else {
                gameOverTextFieldLock()
                let message = "Sorry, you could not guess \(testWord!.wordText!.uppercased())"
                gameOverAlert(with: message)
            }
        } else {
            testWord?.guessed = true
            testWord?.numberOfGuesses = Int16(guessNum)
            saveWords()
            gameOverTextFieldLock()
            let message = "Congratulations! You guessed \(testWord!.wordText!.uppercased()) in \(guessNum) guesses!"
            gameOverAlert(with: message)
        }
    }
    
    func startNextGuess() {
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
            print("Error: NextGuess Function, guessNum not between 2-6")
            break
        }
    }
    
    func gameOverAlert(with message: String) {
        let alert = UIAlertController(title: "Round Over", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func gameOverTextFieldLock() {
        for i in 0...4 {
            currentGuessTextFieldCollection[i].isEnabled = false
        }
    }
    
    //MARK: - Datasource loading - wordList.txt
    //Loads the initial words list from wordList.txt into the CoreData Word entity, used only on first run on device
    func loadWordData() {
        var words = [String]()
        //Used to assign each word an incremented word ID used to search randomly when test word is chosen
        var wordNum = 1
        
        if let wordListURL = Bundle.main.url(forResource: "wordList", withExtension: "txt") {
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
            }
            print("Word List Successfully accessed")
        }

        saveWords()
    }
    
    //MARK: - Keyboard auto increment/decrement functions
    
    //Auto select next text field after user types a letter
    @IBAction func letterChanged(_ sender: UITextField) {
        if(sender.text != "") {
            let currentTextFieldTag = sender.tag
            
            //Formula below ensures when tag is > length of word, resulting number is still between 0 - 4
            userGuess[(sender.tag - (5 * (guessNum - 1)))] = sender.text!
            
            if let nextTextField = self.view.viewWithTag(currentTextFieldTag + 1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        }
    }
    
    //Auto select previous text field when user deletes a lettere
    
    //MARK: - Model Manipulation Methods
    func saveWords() {
        do {
            try context.save()
            print("Save successful")
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func loadTestWord() {
        let request : NSFetchRequest<Word> = Word.fetchRequest()

        
        do {
            let wordListCount = try context.fetch(request).count
            print("Total words in database: \(wordListCount)")
            
            let testWordNum = Int.random(in: 0..<wordListCount)
            let predicate = NSPredicate(format: "wordNumID == %d", Int32(testWordNum))
            request.predicate = predicate
            
            let testWordFetched = try context.fetch(request)
            testWord = testWordFetched[0]
            let testWordString = testWord?.wordText
            for i in 0...4 {
                testWordArray[i] = (testWordString?[i..<(i+1)].uppercased())!
            }
            
            print(testWord!.wordNumID)
            print(testWord!.guessed)
        } catch {
            print("Error fetching category list: \(error)")
        }
    }
}



//MARK: - Keyboard return and string length methods
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkAnswer()
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

//MARK: - String subscript access functions
//To be able to use subscripts on strings to get each letter to populate an array for future guess/test word comparison
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

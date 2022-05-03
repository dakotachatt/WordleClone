//
//  ViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-03-25.
//

import UIKit
import CoreData

class ViewController: UIViewController, DeleteTextFieldDelegate {
    //Text Field Outlets
    @IBOutlet var guess1TextFields: [DeleteTextField]!
    @IBOutlet var guess2TextFields: [DeleteTextField]!
    @IBOutlet var guess3TextFields: [DeleteTextField]!
    @IBOutlet var guess4TextFields: [DeleteTextField]!
    @IBOutlet var guess5TextFields: [DeleteTextField]!
    @IBOutlet var guess6TextFields: [DeleteTextField]!
    @IBOutlet var letterKeyButtons: [UIButton]!
    
    var testWord : Word? = nil
    var testWordArray : [String] = ["", "", "", "", ""]
    var userGuess : [String] = ["", "", "", "", ""]
    var guessColors : [UIColor] = [K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent]
    var currentGuessTextFieldCollection : [UITextField] = []
    var currentTextField : DeleteTextField?
    var guessNum = 1
    
    let defaults = UserDefaults.standard

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateKeyboardColors()
        
        //Set Delegates
        for i in 0...4 {
            self.guess1TextFields[i].delegate = self
            self.guess2TextFields[i].delegate = self
            self.guess3TextFields[i].delegate = self
            self.guess4TextFields[i].delegate = self
            self.guess5TextFields[i].delegate = self
            self.guess6TextFields[i].delegate = self
            self.guess1TextFields[i].deleteTextFieldDelegate = self
            self.guess2TextFields[i].deleteTextFieldDelegate = self
            self.guess3TextFields[i].deleteTextFieldDelegate = self
            self.guess4TextFields[i].deleteTextFieldDelegate = self
            self.guess5TextFields[i].deleteTextFieldDelegate = self
            self.guess6TextFields[i].deleteTextFieldDelegate = self
        }
        
        for i in 0...4 {
            self.guess1TextFields[i].inputView = UIView()
            self.guess2TextFields[i].inputView = UIView()
            self.guess3TextFields[i].inputView = UIView()
            self.guess4TextFields[i].inputView = UIView()
            self.guess5TextFields[i].inputView = UIView()
            self.guess6TextFields[i].inputView = UIView()
        }
        
        //Determines if user has already initially run app on device, and if not, to populate the word list
        let isWordListLoaded = defaults.bool(forKey: "WordListLoaded")
        if(!isWordListLoaded) {
            print("Initial Data Loaded")
            loadWordData()
            defaults.set(true, forKey: "WordListLoaded")
        }
        
        loadTestWord()
        
        currentGuessTextFieldCollection = guess1TextFields
        guess1TextFields[0].becomeFirstResponder()
        currentTextField = guess1TextFields[0]
    }
    
    //MARK: - Gameplay related functions
    //Verifies that word is a real word and spelled correctly
    func isCorrectWord(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.count)
        let incorrectRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return incorrectRange.location == NSNotFound
    }
    
    func checkAnswer() {
        
        //Verifies that guess the user entered is a real word, if not guess is not submitted
        let userGuessString = userGuess.joined(separator: "").lowercased()
        print(userGuessString)
        if (!isCorrectWord(word: userGuessString)) {
            notAWordAlert()
            return
        }
        
        guessColors = [K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent]
        var testWordPlaceholder = testWordArray
        
        for i in 0...4 {
            if userGuess[i] == testWordPlaceholder[i] {
                guessColors[i] = K.Colors.correctLocation
                WordleDataModel.keyboardColors[userGuess[i]] = K.Colors.correctLocation
                
                testWordPlaceholder[i] = ""
            }
        }
        
        for i in 0...4 {
            if testWordPlaceholder.contains(userGuess[i]) && guessColors[i] != K.Colors.correctLocation {
                guessColors[i] = K.Colors.incorrectLocation
                
                if(WordleDataModel.keyboardColors[userGuess[i]] != K.Colors.correctLocation) {
                    if(WordleDataModel.keyboardColors[userGuess[i]] != K.Colors.incorrectLocation) {
                        WordleDataModel.keyboardColors[userGuess[i]] = K.Colors.incorrectLocation
                    }
                }
                
                if let letterIndex = testWordPlaceholder.firstIndex(of: userGuess[i]) {
                    testWordPlaceholder[letterIndex] = ""
                }
            }
        }
        
        for i in 0...4 {
            if(WordleDataModel.keyboardColors[userGuess[i]] != K.Colors.correctLocation) {
                if(WordleDataModel.keyboardColors[userGuess[i]] != K.Colors.incorrectLocation) {
                    WordleDataModel.keyboardColors[userGuess[i]] = K.Colors.letterNotPresent
                }
            }
        }
        
        for i in 0...4 {
            currentGuessTextFieldCollection[i].backgroundColor = guessColors[i]
        }
        
        updateKeyboardColors()
        
        //Used to track whether all letters in a given guess are correct or not - ends game if true after all letters looped through
        var correctLetterCount = 0
        
        for i in 0...4 {
            if(guessColors[i] == K.Colors.correctLocation) {
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
            var message = ""
            
            if(guessNum == 1) {
                message = "Congratulations! You guessed \(testWord!.wordText!.uppercased()) on your first try!"
            } else {
                message = "Congratulations! You guessed \(testWord!.wordText!.uppercased()) in \(guessNum) guesses!"
            }
            
            gameOverAlert(with: message)
        }
    }
    
    func startNextGuess() {
        switch(guessNum) {
        case 1:
            for i in 0...4 {
                guess1TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess1TextFields
                guess1TextFields[0].becomeFirstResponder()
                currentTextField = guess1TextFields[0]
            }
            break
        case 2:
            for i in 0...4 {
                guess1TextFields[i].isEnabled = false
                guess2TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess2TextFields
                guess2TextFields[0].becomeFirstResponder()
                currentTextField = guess2TextFields[0]
            }
            break
        case 3:
            for i in 0...4 {
                guess2TextFields[i].isEnabled = false
                guess3TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess3TextFields
                guess3TextFields[0].becomeFirstResponder()
                currentTextField = guess3TextFields[0]
            }
            break
        case 4:
            for i in 0...4 {
                guess3TextFields[i].isEnabled = false
                guess4TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess4TextFields
                guess4TextFields[0].becomeFirstResponder()
                currentTextField = guess4TextFields[0]
            }
            break
        case 5:
            for i in 0...4 {
                guess4TextFields[i].isEnabled = false
                guess5TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess5TextFields
                guess5TextFields[0].becomeFirstResponder()
                currentTextField = guess5TextFields[0]
            }
            break
        case 6:
            for i in 0...4 {
                guess5TextFields[i].isEnabled = false
                guess6TextFields[i].isEnabled = true
                currentGuessTextFieldCollection = guess6TextFields
                guess6TextFields[0].becomeFirstResponder()
                currentTextField = guess6TextFields[0]
            }
            break
        default:
            print("Error: NextGuess Function, guessNum not between 2-6")
            break
        }
    }
    
    func gameOverAlert(with message: String) {
        let alert = UIAlertController(title: "Round Over", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "One More", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.restart()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func missingLetterAlert() {
        let alert = UIAlertController(title: "Incomplete", message: "All letters must be filled in", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func notAWordAlert() {
        let alert = UIAlertController(title: "Not a Word", message: "You did not enter a real word", preferredStyle: .alert)
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
    
    func restart() {
        for i in 0...4 {
            //Clears all text fields
            guess1TextFields[i].text = ""
            guess2TextFields[i].text = ""
            guess3TextFields[i].text = ""
            guess4TextFields[i].text = ""
            guess5TextFields[i].text = ""
            guess6TextFields[i].text = ""
            guess1TextFields[i].backgroundColor = UIColor.clear
            guess2TextFields[i].backgroundColor = UIColor.clear
            guess3TextFields[i].backgroundColor = UIColor.clear
            guess4TextFields[i].backgroundColor = UIColor.clear
            guess5TextFields[i].backgroundColor = UIColor.clear
            guess6TextFields[i].backgroundColor = UIColor.clear
            
            //Clears most recent user guess from array
            userGuess[i] = ""
        }
        
        for (letter, color) in WordleDataModel.keyboardColors {
            WordleDataModel.keyboardColors[letter] = K.Colors.unusedLetter
        }
        
        updateKeyboardColors()
        
        guessNum = 1
        loadTestWord()
        startNextGuess()
    }
    
    //MARK: - On Screen Keyboard Functions
    func updateKeyboardColors() {
        for i in 0..<letterKeyButtons.count {
            let currentSelection = letterKeyButtons[i]
            currentSelection.backgroundColor = WordleDataModel.keyboardColors[currentSelection.titleLabel!.text!]
            currentSelection.setTitleColor(.black, for: .normal)
            
//            if(currentSelection.backgroundColor == K.Colors.unusedLetter) {
//                currentSelection.tintColor = UIColor.black
//            } else {
//                currentSelection.tintColor = UIColor.white
//            }
        }
    }
    
    @IBAction func letterKeyPressed(_ sender: UIButton) {
        currentTextField?.becomeFirstResponder()
        
//        //If selected text field has a letter in it, move to next text field and replace value, then select next field, else replace value of currently selected field
//        if(currentTextField?.text != "") {
//            letterChanged(currentTextField!)
//            currentTextField?.text = sender.titleLabel?.text
//            letterChanged(currentTextField!)
//        } else {
            currentTextField?.text = sender.titleLabel?.text
            letterChanged(currentTextField!)
//        }
    }
    
    @IBAction func deleteKeyPressed(_ sender: UIButton) {
        currentTextField?.text = ""
        backwardDetected(textField: currentTextField!)
    }
    
    @IBAction func submitKeyPressed(_ sender: UIButton) {
        var noFieldsBlank = true
        
        for i in 0...4 {
            if(currentGuessTextFieldCollection[i].text! == "" || currentGuessTextFieldCollection[i].text! == " ") {
                noFieldsBlank = false
            }
        }
        
        if(noFieldsBlank) {
            checkAnswer()
        } else {
            missingLetterAlert()
        }
    }
    
    
    
    //MARK: - Datasource loading - wordList.txt
    //Loads the initial words list from wordList.txt into the CoreData Word entity, used only on first run on device
    func loadWordData() {
        var words = [String]()
        //Used to assign each word an incremented word ID used to search randomly when test word is chosen
        var wordNum = 1
        
        if let wordListURL = Bundle.main.url(forResource: K.wordListFileName, withExtension: "txt") {
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
    
    //MARK: - User Statistics Functions
    
    @IBAction func statsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.goToStatsSegue, sender: self)
    }
    
    
    //MARK: - Keyboard auto increment/decrement functions
    
    //Auto select next text field after user types a letter
    @IBAction func letterChanged(_ sender: UITextField) {
        if(sender.text != "") {
            let currentTextFieldTag = sender.tag
            
            //Formula below ensures when tag is > length of word, resulting number is still between 0 - 4 when updating userGuess array
            userGuess[(sender.tag - (5 * (guessNum - 1)) - 1)] = sender.text!
            print(userGuess[(sender.tag - (5 * (guessNum - 1)) - 1)])
            
            //Will only move to the next tag if the selected text field is NOT the last field in a guess
            if(sender.tag - (5 * (guessNum - 1)) - 1) < 4 {
                if let nextTextField = self.view.viewWithTag(currentTextFieldTag + 1) as? DeleteTextField {
                    nextTextField.becomeFirstResponder()
                    currentTextField = nextTextField
                }
            }
        }
    }
    
    //Auto select previous text field when user deletes a letter
    func backwardDetected(textField: DeleteTextField) {
        let currentTextFieldTag = textField.tag
        if(currentTextFieldTag - (5 * (guessNum - 1)) != 1) {
            if let previousTextField = self.view.viewWithTag(currentTextFieldTag - 1) as? DeleteTextField {
                previousTextField.becomeFirstResponder()
                currentTextField = previousTextField
            }
        }
    }
    
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
            
            //To loop through and retry until a word that hasn't been guessed has been found, XXXXXX possible infinite loop (when all words have been guessed) work on avoiding
            if(!testWord!.guessed) {
                let testWordString = testWord?.wordText
                for i in 0...4 {
                    testWordArray[i] = (testWordString?[i..<(i+1)].uppercased())!
                }
                
                print(testWord!.wordNumID)
                print(testWord!.guessed)
                print(testWord!.wordText!.uppercased())
            } else {
                loadTestWord()
                print("Word already guessed, picking another")
            }
        } catch {
            print("Error fetching category list: \(error)")
        }
    }
}



//MARK: - Keyboard return and string length methods
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var noFieldsBlank = true
        
        for i in 0...4 {
            if(currentGuessTextFieldCollection[i].text! == "" || currentGuessTextFieldCollection[i].text! == " ") {
                noFieldsBlank = false
            }
        }
        
        if(noFieldsBlank) {
            checkAnswer()
        } else {
            missingLetterAlert()
        }
        return false
    }
    
    //Ensures each text field can only have a single character
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        //Ensures no whitespaces are allowed
        if(updatedText == " ") {
            return false
        }
        
        //Ensures only a single character is returned
        return updatedText.count <= 1
    }
    
    //Highlights the particular cell that is selected for editing as the cursor is no visible to the user
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = 3
        
        if(traitCollection.userInterfaceStyle == .light) {
            textField.layer.borderColor = UIColor.black.cgColor
        } else {
            textField.layer.borderColor = UIColor.white.cgColor
        }
        
        currentTextField = textField as? DeleteTextField
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = 1.0
        
        if(traitCollection.userInterfaceStyle == .light) {
            textField.layer.borderColor = UIColor.black.cgColor
        } else {
            textField.layer.borderColor = UIColor.white.cgColor
        }
        return true
    }
    
}

//MARK: - Custom TextField Class - Detect Backspace Pressed Method/Protocol, Set cursor to end of Textfield on Selection
protocol DeleteTextFieldDelegate: AnyObject {
   func backwardDetected(textField: DeleteTextField)
}

class DeleteTextField: UITextField {
   weak var deleteTextFieldDelegate: DeleteTextFieldDelegate?

   override func deleteBackward() {
       if(text!.isEmpty) {
           self.deleteTextFieldDelegate?.backwardDetected(textField: self)
       }
       
       let endPosition = self.endOfDocument
       self.selectedTextRange = self.textRange(from: endPosition, to: endPosition)
       
       super.deleteBackward()
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

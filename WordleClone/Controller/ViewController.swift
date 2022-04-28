//
//  ViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-03-25.
//

import UIKit
import CoreData

class ViewController: UIViewController, DeleteTextFieldDelegate {

    var testWord : Word? = nil
    var testWordArray : [String] = ["", "", "", "", ""]
    var userGuess : [String] = ["", "", "", "", ""]
    var guessColors : [UIColor] = [K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent]
    var currentGuessTextFieldCollection : [UITextField] = []
    var guessNum = 1
    
    let defaults = UserDefaults.standard

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Text Field Outlets
    @IBOutlet var guess1TextFields: [DeleteTextField]!
    @IBOutlet var guess2TextFields: [DeleteTextField]!
    @IBOutlet var guess3TextFields: [DeleteTextField]!
    @IBOutlet var guess4TextFields: [DeleteTextField]!
    @IBOutlet var guess5TextFields: [DeleteTextField]!
    @IBOutlet var guess6TextFields: [DeleteTextField]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    //MARK: - Gameplay related functions
    func checkAnswer() {
        
        guessColors = [K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent]
        var testWordPlaceholder = testWordArray
        
        for i in 0...4 {
            if userGuess[i] == testWordPlaceholder[i] {
                guessColors[i] = K.Colors.correctLocation
                
                testWordPlaceholder[i] = ""
                print(testWordPlaceholder)
                print(testWordArray)
            }
        }
        
        for i in 0...4 {
            if testWordPlaceholder.contains(userGuess[i]) && guessColors[i] != K.Colors.correctLocation {
                guessColors[i] = K.Colors.incorrectLocation
                
                if let letterIndex = testWordPlaceholder.firstIndex(of: userGuess[i]) {
                    testWordPlaceholder[letterIndex] = ""
                }
                
                print(testWordPlaceholder)
                print(testWordArray)
            }
        }
        
        for i in 0...4 {
            currentGuessTextFieldCollection[i].backgroundColor = guessColors[i]
        }
        
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
            }
            break
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
        
        guessNum = 1
        loadTestWord()
        startNextGuess()
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
            if let nextTextField = self.view.viewWithTag(currentTextFieldTag + 1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        }
    }
    
    //Auto select previous text field when user deletes a letter
    func backwardDetected(textField: DeleteTextField) {
        let currentTextFieldTag = textField.tag
        if(currentTextFieldTag - (5 * (guessNum - 1)) != 1) {
            if let previousTextField = self.view.viewWithTag(currentTextFieldTag - 1) as? DeleteTextField {
                previousTextField.becomeFirstResponder()
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

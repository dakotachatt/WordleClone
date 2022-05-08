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
    
    //On screen keyboard buttons
    @IBOutlet var letterKeyButtons: [UIButton]!
    
    //Top bar labels
    @IBOutlet weak var hintTokenLabel: UILabel!
    
    //Round over popup IBOutlets
    @IBOutlet weak var popupBackgroundView: UIView!
    @IBOutlet weak var roundOverPopupView: UIView!
    @IBOutlet weak var roundOverTitleLabel: UILabel!
    @IBOutlet weak var roundOverTopMessageLabel: UILabel!
    @IBOutlet weak var roundOverLetter1Label: UILabel!
    @IBOutlet weak var roundOverLetter2Label: UILabel!
    @IBOutlet weak var roundOverLetter3Label: UILabel!
    @IBOutlet weak var roundOverLetter4Label: UILabel!
    @IBOutlet weak var roundOverLetter5Label: UILabel!
    @IBOutlet weak var roundOverBottomMessageLabel: UILabel!
    @IBOutlet weak var roundOverTokenImageView: UIImageView!
    
    
    var testWord : Word? = nil
    var testWordArray : [String] = ["", "", "", "", ""]
    var userGuess : [String] = ["", "", "", "", ""]
    var incorrectLocationHintsGiven : [Int] = []
    var correctLocationHintsGiven : [Int] = []
    var guessColors : [UIColor] = [K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent]
    var currentGuessTextFieldCollection : [UITextField] = []
    var currentTextField : DeleteTextField?
    var guessNum = 1
    
    //To detect if word list has been loaded into memory initially and does not require re-loading
    let isWordListLoaded = UserDefaults.standard.bool(forKey: "WordListLoaded")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateKeyboardColors()
        refreshHintTokenLabel()
        
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
        if(!isWordListLoaded) {
            print("Initial Data Loaded")
            loadWordData()
            UserDefaults.standard.set(true, forKey: "WordListLoaded")
        }
        
        loadTestWord()
        
        currentGuessTextFieldCollection = guess1TextFields
        guess1TextFields[0].becomeFirstResponder()
        currentTextField = guess1TextFields[0]
    }
    
    //MARK: - Gameplay related functions
    //Verifies that word is a real word and spelled correctly before the user can submit a guess
    func isCorrectWord(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.count)
        let incorrectRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return incorrectRange.location == NSNotFound
    }
    
    //Marks the keyboard letter (one not already guessed) with a green color and correctly places it in the current guess
    //Loops until all 5 unique indices have been obtained and appended to the correctLocationHintsGiven array
    func correctLocationHint() -> Bool {
        while(correctLocationHintsGiven.count < 5) {
            let randomLetterIndex = Int.random(in: 0...4)
            let currentLetterColor = WordleDataModel.keyboardColors[testWordArray[randomLetterIndex]]
            
            //First block enables duplicate letters to be given as hints, while the second block is for words that haven't initially been hinted at
            if(currentLetterColor == K.Colors.correctLocation) {
                if(!correctLocationHintsGiven.contains(randomLetterIndex)) {
                    correctLocationHintsGiven.append(randomLetterIndex)
                    
                    if(testWordArray.filter{$0 == testWordArray[randomLetterIndex]}.count > 1) {
                        currentGuessTextFieldCollection[randomLetterIndex].text = testWordArray[randomLetterIndex]
                        userGuess[randomLetterIndex] = testWordArray[randomLetterIndex]
                        WordleDataModel.keyboardColors[testWordArray[randomLetterIndex]] = K.Colors.correctLocation
                        guessColors[randomLetterIndex] = K.Colors.correctLocation
                        currentGuessTextFieldCollection[randomLetterIndex].backgroundColor = guessColors[randomLetterIndex]
                        updateKeyboardColors()
                        return true
                    }
                }
            } else {
                if(!correctLocationHintsGiven.contains(randomLetterIndex)) {
                    correctLocationHintsGiven.append(randomLetterIndex)
                }
                
                currentGuessTextFieldCollection[randomLetterIndex].text = testWordArray[randomLetterIndex]
                userGuess[randomLetterIndex] = testWordArray[randomLetterIndex]
                WordleDataModel.keyboardColors[testWordArray[randomLetterIndex]] = K.Colors.correctLocation
                guessColors[randomLetterIndex] = K.Colors.correctLocation
                currentGuessTextFieldCollection[randomLetterIndex].backgroundColor = guessColors[randomLetterIndex]
                updateKeyboardColors()
                return true
            }
        }
        
        return false
    }
    
    //Marks the keyboard letter (one not already guessed) with a yellow color, does not place it in the current guess board
    func incorrectLocationHint() -> Bool {
        while(incorrectLocationHintsGiven.count < 5) {
            let randomLetterIndex = Int.random(in: 0...4)
            let currentLetterColor = WordleDataModel.keyboardColors[testWordArray[randomLetterIndex]]
            
            if(currentLetterColor == K.Colors.incorrectLocation || currentLetterColor == K.Colors.correctLocation) {
                if(!incorrectLocationHintsGiven.contains(randomLetterIndex)) {
                    incorrectLocationHintsGiven.append(randomLetterIndex)
                }
            } else {
                WordleDataModel.keyboardColors[testWordArray[randomLetterIndex]] = K.Colors.incorrectLocation
                updateKeyboardColors()
                return true
            }
        }
        
        return false
    }
    
    func checkAnswer() {
        //Verifies that guess the user entered is a real word, if not guess is not submitted
        let userGuessString = userGuess.joined(separator: "").lowercased()
        
        //Ensures that in the event iOS built in text checker does not recognize a word that is the current answer from the word list, it will still be correct
        if (!isCorrectWord(word: userGuessString) && (userGuessString != testWord?.wordText?.lowercased())) {
            errorAlert("You did not enter a real word")
            return
        }
        
        //Ensures fields cannot be edited while guess check animation is running
        for i in 0...4 {
            currentGuessTextFieldCollection[i].isEnabled = false
        }
        
        guessColors = [K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent, K.Colors.letterNotPresent]
        var testWordPlaceholder = testWordArray
        
        //Determines first letters that are in correct place and removes that letter from the placeholder to ensure it is not used again in future loops
        //also assigns color to keyboard color dictionary for future updating
        for i in 0...4 {
            if userGuess[i] == testWordPlaceholder[i] {
                guessColors[i] = K.Colors.correctLocation
                WordleDataModel.keyboardColors[userGuess[i]] = K.Colors.correctLocation
                
                testWordPlaceholder[i] = ""
            }
        }
        
        //Determines letters that are present in word but in incorrect location, also assigns color to keyboard color dictionary for future updating
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
        
        //Assigns color to keyboard color dictionary for letters not present in word for future updating
        for i in 0...4 {
            if(WordleDataModel.keyboardColors[userGuess[i]] != K.Colors.correctLocation) {
                if(WordleDataModel.keyboardColors[userGuess[i]] != K.Colors.incorrectLocation) {
                    WordleDataModel.keyboardColors[userGuess[i]] = K.Colors.letterNotPresent
                }
            }
        }
                
        guessAnimationAndRoundContinuation()
    }
    
    //Determines whether to move to next guess or if round is over (win or lose)
    func continueRound() {
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
                roundOverPopupMessage(isCorrect: false)
                roundOverPopupDisplay()
                
                //Update account level stats to show loss - XXXXX Put into function
                var totalPlayed = UserDefaults.standard.integer(forKey: "TotalGamesPlayed")
                var currentStreak = UserDefaults.standard.integer(forKey: "CurrentWinStreak")
                var maxStreak = UserDefaults.standard.integer(forKey: "MaxWinStreak")
                
                if(currentStreak > maxStreak) {
                    maxStreak = currentStreak
                    UserDefaults.standard.set(maxStreak, forKey: "MaxWinStreak")
                }
                currentStreak = 0
                UserDefaults.standard.set(currentStreak, forKey: "CurrentWinStreak")
                
                totalPlayed += 1
                UserDefaults.standard.set(totalPlayed, forKey: "TotalGamesPlayed")
                
                saveContext()
            }
        } else {
            //Update stats associated with specific word
            testWord?.guessed = true
            testWord?.numberOfGuesses = Int16(guessNum)
            
            //Update account level stats to show win - XXXXX Put into function
            var totalPlayed = UserDefaults.standard.integer(forKey: "TotalGamesPlayed")
            var totalWins = UserDefaults.standard.integer(forKey: "TotalGamesWon")
            var currentStreak = UserDefaults.standard.integer(forKey: "CurrentWinStreak")
            var maxStreak = UserDefaults.standard.integer(forKey: "MaxWinStreak")
            
            currentStreak += 1
            UserDefaults.standard.set(currentStreak, forKey: "CurrentWinStreak")
            
            if(currentStreak > maxStreak) {
                maxStreak = currentStreak
                UserDefaults.standard.set(maxStreak, forKey: "MaxWinStreak")
            }
            
            totalPlayed += 1
            UserDefaults.standard.set(totalPlayed, forKey: "TotalGamesPlayed")
            
            totalWins += 1
            UserDefaults.standard.set(totalWins, forKey: "TotalGamesWon")
            
            saveContext()
            gameOverTextFieldLock()
            
            roundOverPopupMessage(isCorrect: true)
            roundOverPopupDisplay()
            roundOverTokenDistribution(numOfGuesses: guessNum)
        }
        
        updateKeyboardColors()
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
    
    func guessAnimationAndRoundContinuation() {
        var currentLetterIndex = 0
        
        //Resets the guess letter background color to clear prior to animating them based on their actual color
        for i in 0...4 {
            currentGuessTextFieldCollection[i].backgroundColor = UIColor.clear
        }
        
        currentGuessTextFieldCollection[currentLetterIndex].backgroundColor = self.guessColors[currentLetterIndex]

        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { (timer) in
            currentLetterIndex += 1
            
            if(currentLetterIndex > 4) {
                self.continueRound()
                timer.invalidate()
                return
            }
            
            self.currentGuessTextFieldCollection[currentLetterIndex].backgroundColor = self.guessColors[currentLetterIndex]
        }
    }
    
    func roundOverPopupMessage(isCorrect: Bool) {
        if (isCorrect) {
            if(guessNum > 1) {
                roundOverTitleLabel.text = "You Did It!"
            } else {
                roundOverTitleLabel.text = "Lucky!"
            }
            
            roundOverTopMessageLabel.text = "You guessed"
            
            roundOverLetter1Label.text = testWordArray[0]
            roundOverLetter2Label.text = testWordArray[1]
            roundOverLetter3Label.text = testWordArray[2]
            roundOverLetter4Label.text = testWordArray[3]
            roundOverLetter5Label.text = testWordArray[4]
            
            if(guessNum > 1) {
                roundOverBottomMessageLabel.text = "in \(guessNum) guesses!"
            } else {
                roundOverBottomMessageLabel.text = "on your first try!"
            }
            
            switch (guessNum) {
            case 1:
                roundOverTokenImageView.image = UIImage(named: "100Tokens.png")
                break
            case 2:
                roundOverTokenImageView.image = UIImage(named: "25Tokens.png")
                break
            case 3:
                roundOverTokenImageView.image = UIImage(named: "20Tokens.png")
                break
            case 4:
                roundOverTokenImageView.image = UIImage(named: "15Tokens.png")
                break
            case 5:
                roundOverTokenImageView.image = UIImage(named: "10Tokens.png")
                break
            case 6:
                roundOverTokenImageView.image = UIImage(named: "5Tokens.png")
                break
            default:
                break
                
            }
        } else {
            roundOverTitleLabel.text = "Uh-Oh!"
            roundOverTopMessageLabel.text = "You couldn't guess"
            
            roundOverLetter1Label.text = testWordArray[0]
            roundOverLetter2Label.text = testWordArray[1]
            roundOverLetter3Label.text = testWordArray[2]
            roundOverLetter4Label.text = testWordArray[3]
            roundOverLetter5Label.text = testWordArray[4]
            
            roundOverBottomMessageLabel.text = "Better Luck Next Time!"
            
            roundOverTokenImageView.image = UIImage(named: "0Tokens.png")
        }
        
        //Update colours in test word label stack in round over popup window
        roundOverLetter1Label.backgroundColor = WordleDataModel.keyboardColors[testWordArray[0]]
        roundOverLetter2Label.backgroundColor = WordleDataModel.keyboardColors[testWordArray[1]]
        roundOverLetter3Label.backgroundColor = WordleDataModel.keyboardColors[testWordArray[2]]
        roundOverLetter4Label.backgroundColor = WordleDataModel.keyboardColors[testWordArray[3]]
        roundOverLetter5Label.backgroundColor = WordleDataModel.keyboardColors[testWordArray[4]]
    }
    
    func roundOverPopupDisplay() {
        popupBackgroundView.isHidden = false
        roundOverPopupView.isHidden = false
        roundOverPopupView.alpha = 0
        popupBackgroundView.alpha = 0
        self.view.bringSubviewToFront(popupBackgroundView)
        self.view.bringSubviewToFront(roundOverPopupView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.popupBackgroundView.alpha = 0.5
            self.roundOverPopupView.alpha = 1
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.popupBackgroundView.isHidden = true
            self.roundOverPopupView.isHidden = true
            self.restart()
        }
    }
    
    func roundOverTokenDistribution(numOfGuesses: Int) {
        var totalTokens = UserDefaults.standard.integer(forKey: "HintTokens")
        
        if (numOfGuesses == 1) {
            totalTokens += 100
            UserDefaults.standard.set(totalTokens, forKey: "HintTokens")
        } else if (numOfGuesses <= 6 && numOfGuesses > 1) {
            totalTokens += (25 - 5 * (numOfGuesses - 2))
            UserDefaults.standard.set(totalTokens, forKey: "HintTokens")
        }
    }
    
    func errorAlert(_ message: String) {
        let alert = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
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
        
        incorrectLocationHintsGiven = []
        correctLocationHintsGiven = []
        
        updateKeyboardColors()
        
        guessNum = 1
        refreshHintTokenLabel()
        loadTestWord()
        startNextGuess()
    }
    
    func refreshHintTokenLabel() {
        hintTokenLabel.text = String(UserDefaults.standard.integer(forKey: "HintTokens"))
    }
    
    //MARK: - On Screen Keyboard Functions
    func updateKeyboardColors() {
        for i in 0..<letterKeyButtons.count {
            let currentSelection = letterKeyButtons[i]
            currentSelection.backgroundColor = WordleDataModel.keyboardColors[currentSelection.titleLabel!.text!]
            currentSelection.setTitleColor(.black, for: .normal)
        }
    }
    
    @IBAction func letterKeyPressed(_ sender: UIButton) {
        currentTextField?.becomeFirstResponder()
        
        //If the current text field has a letter but the next field is empty, do not overwrite the current text field and move to and fill in the letter in next text field
        //If the current text field has a letter AND the next field does also, overwrite the current text field letter and move to the next text field
        //If the current text field is the final text field in a particular guess, fill in the letter or overwrite if a letter is already in place
        if (currentTextField!.isEnabled) {
            if (currentTextField!.text != "") {
                if(currentTextField!.tag - (5 * (guessNum - 1)) - 1) < 4 {
                    if let nextTextField = self.view.viewWithTag(currentTextField!.tag + 1) as? DeleteTextField {
                        if (nextTextField.text != "") {
                            currentTextField?.text = sender.titleLabel?.text
                            currentTextField?.backgroundColor = UIColor.clear
                            letterChanged(currentTextField!)
                        } else if (nextTextField.text == "") {
                            letterChanged(currentTextField!)
                            currentTextField?.text = sender.titleLabel?.text
                            currentTextField?.backgroundColor = UIColor.clear
                            letterChanged(currentTextField!)
                        }
                    }
                } else {
                    currentTextField?.text = sender.titleLabel?.text
                    currentTextField?.backgroundColor = UIColor.clear
                    letterChanged(currentTextField!)
                }
            }  else {
                currentTextField?.text = sender.titleLabel?.text
                currentTextField?.backgroundColor = UIColor.clear
                letterChanged(currentTextField!)
            }
        }
    }
    
    @IBAction func deleteKeyPressed(_ sender: UIButton) {
        if(currentTextField!.isEnabled) {
            currentTextField?.text = ""
            currentTextField?.backgroundColor = UIColor.clear
            backwardDetected(textField: currentTextField!)
        }
    }
    
    @IBAction func submitKeyPressed(_ sender: UIButton) {
        if(currentTextField!.isEnabled) {
            var noFieldsBlank = true
            
            for i in 0...4 {
                if(currentGuessTextFieldCollection[i].text! == "" || currentGuessTextFieldCollection[i].text! == " ") {
                    noFieldsBlank = false
                }
            }
            
            if(noFieldsBlank) {
                checkAnswer()
            } else {
                errorAlert("All letters must be filled in")
            }
        }
    }
    
    @IBAction func incorrectLocationHintPressed(_ sender: UIButton) {
        var currentTokens = UserDefaults.standard.integer(forKey: "HintTokens")
        
        if(currentTokens >= 50) {
            let isValidHint = incorrectLocationHint()
            if(isValidHint) {
                UserDefaults.standard.set(currentTokens - 50, forKey: "HintTokens")
                refreshHintTokenLabel()
            } else {
                errorAlert("All letters have been found!")
            }
        } else {
            errorAlert("Not enough tokens!")
        }
    }
    
    @IBAction func correctLocationHintPressed(_ sender: UIButton) {
        var currentTokens = UserDefaults.standard.integer(forKey: "HintTokens")
        
        if(currentTokens >= 100) {
            let isValidHint = correctLocationHint()
            if (isValidHint) {
                UserDefaults.standard.set(currentTokens - 100, forKey: "HintTokens")
                refreshHintTokenLabel()
            } else {
                errorAlert("All letters and locations have been found!")
            }
        } else {
            errorAlert("Not enough tokens!")
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

        saveContext()
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
    func saveContext() {
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
            errorAlert("All letters must be filled in")
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

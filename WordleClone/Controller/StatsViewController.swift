//
//  StatsViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-04-01.
//

import UIKit
import CoreData

class StatsViewController: UIViewController {

    //Stat Labels
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var percentWonLabel: UILabel!
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var maxStreakLabel: UILabel!
    @IBOutlet weak var averageGuessLabel: UILabel!
    @IBOutlet weak var oneGuessBar: UIProgressView!
    @IBOutlet weak var twoGuessBar: UIProgressView!
    @IBOutlet weak var threeGuessBar: UIProgressView!
    @IBOutlet weak var fourGuessBar: UIProgressView!
    @IBOutlet weak var fiveGuessBar: UIProgressView!
    @IBOutlet weak var sixGuessBar: UIProgressView!
    
    
    var guessedWordArray : [Word] = []
    
    let totalPlayed = UserDefaults.standard.integer(forKey: "TotalGamesPlayed")
    let totalWins = UserDefaults.standard.integer(forKey: "TotalGamesWon")
    let currentStreak = UserDefaults.standard.integer(forKey: "CurrentWinStreak")
    let maxStreak = UserDefaults.standard.integer(forKey: "MaxWinStreak")
    var winPercentage : Float = 0
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadWordStats()
        loadAccountStats()
    }
    
    func loadAccountStats() {
        if(totalPlayed > 0) {
            winPercentage = (Float(totalWins) / Float(totalPlayed)) * 100
        }
        
        gamesPlayedLabel.text = String(format: "%d", totalPlayed)
        percentWonLabel.text = String(format: "%.0f%%", winPercentage)
        currentStreakLabel.text = String(format: "%d", currentStreak)
        maxStreakLabel.text = String(format: "%d", maxStreak)
    }
    
    func loadWordStats() {
        let request : NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let guessedWordPredicate = NSPredicate(format: "guessed == YES")
            request.predicate = guessedWordPredicate
            
            guessedWordArray = try context.fetch(request)
            
            var oneGuess : Float = 0.0
            var twoGuess : Float  = 0.0
            var threeGuess : Float  = 0.0
            var fourGuess : Float  = 0.0
            var fiveGuess : Float  = 0.0
            var sixGuess : Float  = 0.0
            var guessSum : Float  = 0.0
            
            for i in 0..<guessedWordArray.count {
                switch (guessedWordArray[i].numberOfGuesses) {
                case 1:
                    oneGuess += 1.0
                    guessSum += 1.0
                    break
                case 2:
                    twoGuess += 1.0
                    guessSum += 2.0
                    break
                case 3:
                    threeGuess += 1.0
                    guessSum += 3.0
                    break
                case 4:
                    fourGuess += 1.0
                    guessSum += 4.0
                    break
                case 5:
                    fiveGuess += 1.0
                    guessSum += 5.0
                    break
                case 6:
                    sixGuess += 1.0
                    guessSum += 6.0
                    break
                default:
                    break
                }
            }
            
            oneGuessBar.setProgress((oneGuess / Float(totalWins)), animated: true)
            twoGuessBar.setProgress((twoGuess / Float(totalWins)), animated: true)
            threeGuessBar.setProgress((threeGuess / Float(totalWins)), animated: true)
            fourGuessBar.setProgress((fourGuess / Float(totalWins)), animated: true)
            fiveGuessBar.setProgress((fiveGuess / Float(totalWins)), animated: true)
            sixGuessBar.setProgress((sixGuess / Float(totalWins)), animated: true)
            averageGuessLabel.text = String(format: "%.1f", guessSum / Float(totalWins))
        } catch {
            print("Error retrieving guessed word stats: \(error)")
        }
    }
}

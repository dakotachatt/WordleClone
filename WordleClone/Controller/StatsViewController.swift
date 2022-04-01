//
//  StatsViewController.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-04-01.
//

import UIKit
import CoreData

class StatsViewController: UIViewController {

    @IBOutlet weak var totalCorrectLabel: UILabel!
    @IBOutlet weak var oneGuessLabel: UILabel!
    @IBOutlet weak var twoGuessLabel: UILabel!
    @IBOutlet weak var threeGuessLabel: UILabel!
    @IBOutlet weak var fourGuessLabel: UILabel!
    @IBOutlet weak var fiveGuessLabel: UILabel!
    @IBOutlet weak var sixGuessLabel: UILabel!
    @IBOutlet weak var avgGuessLabel: UILabel!
    
    var guessedWordArray : [Word] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadStats()
    }
    
    func loadStats() {
        let request : NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let totalWordCount = try context.fetch(request).count
            
            let guessedWordPredicate = NSPredicate(format: "guessed == YES")
            request.predicate = guessedWordPredicate
            
            guessedWordArray = try context.fetch(request)
            
            let totalGuessed = Float(guessedWordArray.count)
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
            
            totalCorrectLabel.text = String(format: "%d / %d", Int(totalGuessed), Int(totalWordCount))
            oneGuessLabel.text = String(format: "%.0f%% (%d)", (oneGuess/totalGuessed) * 100, Int(oneGuess))
            twoGuessLabel.text = String(format: "%.0f%% (%d)", (twoGuess/totalGuessed) * 100, Int(twoGuess))
            threeGuessLabel.text = String(format: "%.0f%% (%d)", (threeGuess/totalGuessed) * 100, Int(threeGuess))
            fourGuessLabel.text = String(format: "%.0f%% (%d)", (fourGuess/totalGuessed) * 100, Int(fourGuess))
            fiveGuessLabel.text = String(format: "%.0f%% (%d)", (fiveGuess/totalGuessed) * 100, Int(fiveGuess))
            sixGuessLabel.text = String(format: "%.0f%% (%d)", (sixGuess/totalGuessed) * 100, Int(sixGuess))
            avgGuessLabel.text = String(format: "%.1f", guessSum/totalGuessed)
        } catch {
            print("Error retrieving guessed word stats: \(error)")
        }
    }
}

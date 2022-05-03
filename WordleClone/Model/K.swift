//
//  K.swift
//  WordleClone
//
//  Created by Dakota Chatt on 2022-04-01.
//

import Foundation
import UIKit

struct K {
    
    static let applicationTitle = "Wordle Clone"
    static let wordListFileName = "wordList"
    
    struct Colors {
        static let correctLocation : UIColor = UIColor(red: 0.42, green: 0.67, blue: 0.39, alpha: 1.00)
        static let incorrectLocation : UIColor = UIColor(red: 0.79, green: 0.71, blue: 0.34, alpha: 1.00)
        static let letterNotPresent : UIColor = UIColor(red: 0.47, green: 0.49, blue: 0.50, alpha: 1.00)
        static let unusedLetter : UIColor = UIColor.systemGray6
    }
    
    struct Segues {
        static let goToGameSegue = "goToGame"
        static let goToStatsSegue = "goToStats"
    }
}

# WordleClone
Clone of the 5 letter word guessing game

Additional features beyond the traditional Wordle Web Browser Game has been added:
  - Able to select individual letters rather than have to backspace to the letter(s) you want to change
  - Hint system, for correct letter with no particular placement, and both correct letter and placement costing various tokens
  - Tokens are awarded based on correct guesses and how many it took to guess
  - Sound effects for error messages, winning and losing rounds and using tokens
  - Uses built in iOS text checker to verify words are correct
  - Large 5700 5 letter english word list

To run:
Clone project in your own Xcode environment - must have at least a free iOS developer account to run. Change the team and bundle identifier to your own.
Simply run app on device or in simulator and word list will load upon first playing. 
User will start with 500 free hint tokens and will need to earn additional tokens beyond that.

Rules:
  - English words only
  - 6 Guesses total
  - Dark grey means letter is not present in the word. Yellow means it is present but currently in an incorrect location. Green means correct letter and location
  - Only real words are allowed for guesses
  - Two types of hints, costing different amounts of hint tokens as displayed.
  - If words is not guessed in 6 tries, round is lost and no tokens are awarded.

Stats can be accessed in the top right of the game screen and will update after each round is played.

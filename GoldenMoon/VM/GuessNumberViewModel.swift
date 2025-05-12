//
//  GuessNumberViewModel.swift
//  GoldenMoon
//
//  Created by Alex on 11.05.2025.
//

import SwiftUI
import Combine

class GuessNumberViewModel: ObservableObject {
    enum GuessGameState: Equatable {
        case playing
        case guessed(correct: Bool, message: String)
    }
    
    @Published private(set) var gameState: GuessGameState = .playing
    @Published private(set) var targetNumber: Int = 0
    @Published private(set) var attempts: Int = 0
    @Published private(set) var feedbackMessage: String = "Try to guess the number"
    
    private let minNumber = 0
    private let maxNumber = 999
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        targetNumber = Int.random(in: minNumber...maxNumber)
        attempts = 0
        feedbackMessage = "Try to guess the number"
        gameState = .playing
    }
    
    func makeGuess(_ guess: Int) {
        attempts += 1
        
        if guess == targetNumber {
            feedbackMessage = "Correct! You guessed it in \(attempts) attempts."
            gameState = .guessed(correct: true, message: feedbackMessage)
        } else if guess < targetNumber {
            feedbackMessage = "Higher! The number is greater than \(guess)."
            gameState = .guessed(correct: false, message: feedbackMessage)
        } else {
            feedbackMessage = "Lower! The number is less than \(guess)."
            gameState = .guessed(correct: false, message: feedbackMessage)
        }
    }
    
    func continueGame() {
        gameState = .playing
    }
}

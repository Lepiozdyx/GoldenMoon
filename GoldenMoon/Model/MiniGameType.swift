//
//  MiniGameType.swift
//  GoldenMoon

import Foundation

enum MiniGameType: String, Codable, CaseIterable, Identifiable {
    case guessNumber = "guess_number"
    case memoryCards = "memory_cards"
    case sequence = "sequence"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .guessNumber: return "Guess the number"
        case .memoryCards: return "Find a match"
        case .sequence: return "Repeat the sequence"
        }
    }
    
    var reward: Int {
        switch self {
        case .guessNumber: return 30
        case .memoryCards: return 30
        case .sequence: return 30
        }
    }
}

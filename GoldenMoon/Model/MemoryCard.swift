//
//  MemoryCard.swift
//  GoldenMoon


import SwiftUI

enum MemoryGameConstants {
    static let gameDuration: TimeInterval = 45
    static let pairsCount = 6
}

enum MemoryCardImage: Int, CaseIterable {
    case card1 = 1
    case card2
    case card3
    case card4
    case card5
    case card6
    
    var imageName: String {
        switch self {
        case .card1: return "memory_card_1"
        case .card2: return "memory_card_2"
        case .card3: return "memory_card_3"
        case .card4: return "memory_card_4"
        case .card5: return "memory_card_5"
        case .card6: return "memory_card_6"
        }
    }
}

enum MemoryCardState {
    case down
    case up
    case matched
}

enum MemoryGameState: Equatable {
    case playing
    case finished(success: Bool)
}

struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let imageIdentifier: Int
    var state: MemoryCardState = .down
    let position: Position
    
    struct Position: Equatable {
        let row: Int
        let column: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            lhs.row == rhs.row && lhs.column == rhs.column
        }
    }
    
    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        lhs.id == rhs.id
    }
}

struct MemoryBoardConfiguration {
    static func generateCards() -> [MemoryCard] {
        var cards: [MemoryCard] = []
        let totalPairs = MemoryGameConstants.pairsCount
        
        for i in 1...totalPairs {
            for _ in 1...2 {
                cards.append(MemoryCard(imageIdentifier: i, position: .init(row: 0, column: 0)))
            }
        }
        
        cards.shuffle()
        
        var index = 0
        for row in 0..<3 {
            for column in 0..<4 {
                guard index < cards.count else { break }
                
                cards[index] = MemoryCard(
                    imageIdentifier: cards[index].imageIdentifier,
                    position: .init(row: row, column: column)
                )
                index += 1
            }
        }
        
        return cards
    }
}

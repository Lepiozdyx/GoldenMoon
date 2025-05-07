//
//  MillPiece.swift
//  GoldenMoon

import SwiftUI

struct MillPiece: Identifiable, Equatable {
    let id = UUID()
    let player: MillPlayerType
    
    var color: Color {
        switch player {
        case .player1:
            return .red
        case .player2:
            return .blue
        case .none:
            return .clear
        }
    }
    
    static func == (lhs: MillPiece, rhs: MillPiece) -> Bool {
        return lhs.id == rhs.id && lhs.player == rhs.player
    }
}

enum MillPlayerType: Int, Codable {
    case none = 0
    case player1 = 1
    case player2 = 2
    
    var opponent: MillPlayerType {
        switch self {
        case .player1:
            return .player2
        case .player2:
            return .player1
        case .none:
            return .none
        }
    }
}

//
//  SidePiecesView.swift
//  GoldenMoon

import SwiftUI

struct SidePiecesView: View {
    let player: MillPlayerType
    let piecesCount: Int
    let pieceSize: CGFloat
    let gameMode: MillGameMode
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Image(.medal)
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .overlay(alignment: .top) {
                    Image(.labelGroup)
                        .resizable()
                        .frame(width: 90, height: 35)
                        .overlay {
                            Text(playerName)
                                .customFont(10)
                        }
                        .offset(y: -15)
                }
            
            Image(.brownellipse)
                .resizable()
                .scaledToFit()
                .frame(width: 110)
                .overlay {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(0..<piecesCount, id: \.self) { _ in
                            PieceView(player: player, size: pieceSize, isSelected: false)
                        }
                    }
                    .frame(width: 60)
                }

        }
    }
    
    private var playerName: String {
        switch gameMode {
        case .tutorial:
            return player == .player1 ? "You" : "Opponent"
        case .twoPlayers:
            return player == .player1 ? "Player 1" : "Player 2"
        case .vsAI:
            return player == .player1 ? "You" : "AI"
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        SidePiecesView(player: .player1, piecesCount: 9, pieceSize: 15, gameMode: .twoPlayers)
    }
}

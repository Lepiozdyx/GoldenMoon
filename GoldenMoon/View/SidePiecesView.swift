//
//  SidePiecesView.swift
//  GoldenMoon

import SwiftUI

struct SidePiecesView: View {
    let player: MillPlayerType
    let piecesCount: Int
    let pieceSize: CGFloat
    
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
                            Text(player == .player1 ? "You" : "Opponent")
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
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        SidePiecesView(player: .player1, piecesCount: 9, pieceSize: 15)
    }
}

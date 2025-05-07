//
//  SidePiecesView.swift
//  GoldenMoon

import SwiftUI

struct SidePiecesView: View {
    let player: MillPlayerType
    let piecesCount: Int
    let pieceSize: CGFloat
    let onPieceSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text(player == .player1 ? "Your Pieces" : "Opponent's Pieces")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 4) {
                ForEach(0..<piecesCount, id: \.self) { _ in
                    PieceView(player: player, size: pieceSize, isSelected: false)
                        .onTapGesture {
                            if player == .player1 {
                                onPieceSelected()
                            }
                        }
                }
            }
            .padding(.vertical)
        }
        .padding()
    }
}

#Preview {
    SidePiecesView(player: .player1, piecesCount: 9, pieceSize: 30, onPieceSelected: {})
}

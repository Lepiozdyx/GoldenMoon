//
//  PieceView.swift
//  GoldenMoon

import SwiftUI

struct PieceView: View {
    let player: MillPlayerType
    let size: CGFloat
    let isSelected: Bool
    
    var body: some View {
        Circle()
            .fill(pieceColor)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.yellow : Color.white, lineWidth: isSelected ? 3 : 1)
            )
            .shadow(color: pieceColor.opacity(0.6), radius: isSelected ? 5 : 2)
    }
    
    private var pieceColor: Color {
        switch player {
        case .player1:
            return .red
        case .player2:
            return .blue
        case .none:
            return .clear
        }
    }
}

#Preview {
    PieceView(player: .player1, size: 100, isSelected: true)
}

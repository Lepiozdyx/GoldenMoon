//
//  PieceView.swift
//  GoldenMoon

import SwiftUI

struct PieceView: View {
    let player: MillPlayerType
    let size: CGFloat
    let isSelected: Bool
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        Image(pieceImage)
            .resizable()
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: isSelected ? 5 : 0)
            )
            .shadow(color: .black.opacity(0.3), radius: isSelected ? 5 : 2)
    }
    
    private var pieceImage: ImageResource {
        switch player {
        case .player1:
            return appViewModel.currentChipSkin.player1
        case .player2:
            return appViewModel.currentChipSkin.player2
        case .none:
            return .chip1
        }
    }
}

#Preview {
    PieceView(player: .player1, size: 100, isSelected: true)
        .environmentObject(AppViewModel())
}

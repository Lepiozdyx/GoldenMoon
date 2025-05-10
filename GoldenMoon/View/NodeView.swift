//
//  NodeView.swift
//  GoldenMoon

import SwiftUI

struct NodeView: View {
    let node: MillNode
    let nodeSize: CGFloat
    let onTap: () -> Void
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            // Фон узла
            Circle()
                .fill(node.isHighlighted ? Color.yellow.opacity(0.7) : Color.clear)
                .frame(width: nodeSize * 1.5, height: nodeSize * 1.5)
            
            // Сам узел
            Circle()
                .foregroundStyle(.coffe)
                .frame(width: nodeSize, height: nodeSize)
            
            // Фишка на узле (если есть)
            if let piece = node.piece {
                PieceView(
                    player: piece.player,
                    size: nodeSize * 0.8,
                    isSelected: false
                )
                .environmentObject(appViewModel)
            }
        }
        .contentShape(Circle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    NodeView(
        node: MillNode(id: 1, position: CGPoint(x: 100, y: 100), connections: []),
        nodeSize: 100,
        onTap: {}
    )
    .environmentObject(AppViewModel())
}

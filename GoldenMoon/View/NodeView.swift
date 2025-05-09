//
//  NodeView.swift
//  GoldenMoon

import SwiftUI

struct NodeView: View {
    let node: MillNode
    let nodeSize: CGFloat
    let onTap: () -> Void
    
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
                .overlay(
                    node.piece != nil ?
                    Circle()
                        .fill(node.piece!.color)
                        .frame(width: nodeSize * 0.8, height: nodeSize * 0.8)
                    : nil
                )
        }
        .contentShape(Circle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    NodeView(node: .init(id: 1, position: CGPoint(x: 100, y: 100), connections: []), nodeSize: 100, onTap: {})
}

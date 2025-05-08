//
//  GameBoardView.swift
//  GoldenMoon

import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: MillGameViewModel
    let onNodeTap: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Определяем центр и размеры
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let maxRadius = min(geometry.size.width, geometry.size.height) * 0.4
                let middleRadius = maxRadius * 0.66
                let innerRadius = maxRadius * 0.33
                let nodeSize: CGFloat = maxRadius * 0.1
                
                // Фон игрового поля
                Image(.medal)
                    .resizable()
                    .frame(width: maxRadius * 2.3, height: maxRadius * 2.3)
                
                Image(.desk)
                    .resizable()
                    .frame(width: maxRadius * 2.2, height: maxRadius * 2.2)
                
                // Рисуем кольца
                ForEach([maxRadius, middleRadius, innerRadius], id: \.self) { radius in
                    Circle()
                        .stroke(Color.coffe, lineWidth: 6)
                        .frame(width: radius * 2, height: radius * 2)
                }
                
                // Рисуем радиальные линии
                Path { path in
                    // Горизонтальная линия
                    path.move(to: CGPoint(x: center.x - maxRadius, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + maxRadius, y: center.y))
                    
                    // Вертикальная линия
                    path.move(to: CGPoint(x: center.x, y: center.y - maxRadius))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + maxRadius))
                }
                .stroke(Color.coffe, lineWidth: 6)
                
                Image(.moon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                
                // Подсвечиваем мельницы
                if let lastMillNodeId = viewModel.game.lastMillFormedAt,
                   viewModel.game.millFormed {
                    ForEach(viewModel.game.board.getAllMills(for: viewModel.game.currentPlayer), id: \.self) { mill in
                        if mill.contains(lastMillNodeId) {
                            Path { path in
                                var isFirstPoint = true
                                
                                for nodeId in mill {
                                    if let node = viewModel.game.board.getNode(id: nodeId) {
                                        let nodePosition = getNodePosition(node: node, center: center, maxRadius: maxRadius, middleRadius: middleRadius, innerRadius: innerRadius)
                                        
                                        if isFirstPoint {
                                            path.move(to: nodePosition)
                                            isFirstPoint = false
                                        } else {
                                            path.addLine(to: nodePosition)
                                        }
                                    }
                                }
                                
                                // Замыкаем путь, если это треугольник
                                if mill.count == 3, let firstNodeId = mill.first,
                                   let firstNode = viewModel.game.board.getNode(id: firstNodeId) {
                                    let firstPosition = getNodePosition(node: firstNode, center: center, maxRadius: maxRadius, middleRadius: middleRadius, innerRadius: innerRadius)
                                    path.addLine(to: firstPosition)
                                }
                            }
                            .stroke(viewModel.game.currentPlayer == .player1 ? Color.red.opacity(0.7) : Color.blue.opacity(0.7), lineWidth: 4)
                        }
                    }
                }
                
                // Размещаем узлы с анимацией для переходов
                ForEach(viewModel.game.board.nodes) { node in
                    let nodePosition = getNodePosition(node: node, center: center, maxRadius: maxRadius, middleRadius: middleRadius, innerRadius: innerRadius)
                    
                    NodeView(node: node, nodeSize: nodeSize, onTap: {
                        onNodeTap(node.id)
                    })
                    .position(nodePosition)
                    .animation(.easeInOut, value: node.piece)
                    .animation(.easeInOut, value: node.isHighlighted)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            // Добавляем анимацию при обновлении игрового поля
            .animation(.easeInOut(duration: 0.3), value: viewModel.game.board.nodes)
        }
    }
    
    private func getNodePosition(node: MillNode, center: CGPoint, maxRadius: CGFloat, middleRadius: CGFloat, innerRadius: CGFloat) -> CGPoint {
        // Определяем радиус для узла
        let radius: CGFloat
        if node.id < 8 {
            radius = maxRadius
        } else if node.id < 16 {
            radius = middleRadius
        } else {
            radius = innerRadius
        }
        
        // Вычисляем угол для узла в зависимости от его позиции в кольце
        let ringPosition = node.id % 8
        let angle = Double(ringPosition) * .pi / 4
        
        return CGPoint(
            x: center.x + radius * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(sin(angle))
        )
    }
}

#Preview {
    GameBoardView(viewModel: MillGameViewModel(), onNodeTap: {_ in })
}

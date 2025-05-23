//
//  GameBoardView.swift
//  GoldenMoon

import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: MillGameViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    let onNodeTap: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Определяем центр и базовые размеры
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                // Установим фиксированный максимальный размер для игрового поля
                let boardSize = min(geometry.size.width, geometry.size.height) * 0.8
                
                // Фон игрового поля
                Image(.medal)
                    .resizable()
                    .frame(width: boardSize * 1.15, height: boardSize * 1.15)
                    .position(center)
                
                // Основа игрового поля
                Image(.desk)
                    .resizable()
                    .frame(width: boardSize * 1.1, height: boardSize * 1.1)
                    .position(center)
                
                // Размещаем игровое поле
                let maxRadius = boardSize * 0.35
                let middleRadius = maxRadius * 0.66
                let innerRadius = maxRadius * 0.33
                let nodeSize: CGFloat = maxRadius * 0.18
                
                // Рисуем кольца
                ForEach([maxRadius, middleRadius, innerRadius], id: \.self) { radius in
                    Circle()
                        .stroke(Color.coffe, lineWidth: 4)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                }
                
                // Рисуем радиальные линии с разрывом во внутреннем кольце
                Path { path in
                    // Горизонтальная линия (левая часть)
                    path.move(to: CGPoint(x: center.x - maxRadius, y: center.y))
                    path.addLine(to: CGPoint(x: center.x - innerRadius, y: center.y))
                    
                    // Горизонтальная линия (правая часть)
                    path.move(to: CGPoint(x: center.x + innerRadius, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + maxRadius, y: center.y))
                    
                    // Вертикальная линия (верхняя часть)
                    path.move(to: CGPoint(x: center.x, y: center.y - maxRadius))
                    path.addLine(to: CGPoint(x: center.x, y: center.y - innerRadius))
                    
                    // Вертикальная линия (нижняя часть)
                    path.move(to: CGPoint(x: center.x, y: center.y + innerRadius))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + maxRadius))
                }
                .stroke(Color.coffe, lineWidth: 4)
                
                Image(.moon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: innerRadius)
                    .position(center)
                
                // Подсвечиваем мельницы
                if let lastMillNodeId = viewModel.game.lastMillFormedAt,
                   viewModel.game.millFormed {
                    ForEach(viewModel.game.board.getAllMills(for: viewModel.game.currentPlayer), id: \.self) { mill in
                        if mill.contains(lastMillNodeId) {
                            Path { path in
                                var isFirstPoint = true
                                
                                for nodeId in mill {
                                    if let node = viewModel.game.board.getNode(id: nodeId) {
                                        let nodePosition = getNodePosition(
                                            node: node,
                                            center: center,
                                            maxRadius: maxRadius,
                                            middleRadius: middleRadius,
                                            innerRadius: innerRadius
                                        )
                                        
                                        if isFirstPoint {
                                            path.move(to: nodePosition)
                                            isFirstPoint = false
                                        } else {
                                            path.addLine(to: nodePosition)
                                        }
                                    }
                                }
                            }
                            .stroke(
                                viewModel.game.currentPlayer == .player1
                                    ? Color.red.opacity(0.7)
                                    : Color.blue.opacity(0.7),
                                lineWidth: 4
                            )
                        }
                    }
                }
                
                // Размещаем узлы
                ForEach(viewModel.game.board.nodes) { node in
                    let nodePosition = getNodePosition(
                        node: node,
                        center: center,
                        maxRadius: maxRadius,
                        middleRadius: middleRadius,
                        innerRadius: innerRadius
                    )
                    
                    NodeView(node: node, nodeSize: nodeSize, onTap: {
                        onNodeTap(node.id)
                    })
                    .environmentObject(appViewModel)
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
        .environmentObject(AppViewModel())
}

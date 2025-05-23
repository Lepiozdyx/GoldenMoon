//
//  MillBoard.swift
//  GoldenMoon

import Foundation
import SwiftUI

class MillBoard: ObservableObject {
    @Published var nodes: [MillNode]
    let millLines: [Set<Int>]
    
    init() {
        // Инициализация узлов игрового поля
        var initialNodes: [MillNode] = []
        
        // Формируем внешнее кольцо (8 узлов)
        let outerRadius: CGFloat = 150
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let x = cos(angle) * outerRadius
            let y = sin(angle) * outerRadius
            
            // Определяем соединения для внешнего кольца
            var connections: [Int] = []
            
            // Соединение с соседями в кольце
            let prevIndex = (i - 1 + 8) % 8
            let nextIndex = (i + 1) % 8
            connections.append(prevIndex)
            connections.append(nextIndex)
            
            // Если это узел на радиальной линии (0, 2, 4, 6), соединяем с средним кольцом
            if i % 2 == 0 {
                connections.append(8 + i)  // Исправлено: было 8 + i/2
            }
            
            initialNodes.append(MillNode(id: i, position: CGPoint(x: x, y: y), connections: connections))
        }
        
        // Формируем среднее кольцо (8 узлов)
        let middleRadius: CGFloat = 100
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let x = cos(angle) * middleRadius
            let y = sin(angle) * middleRadius
            
            // Определяем соединения для среднего кольца
            var connections: [Int] = []
            
            // Соединение с соседями в кольце
            let prevIndex = ((i - 1 + 8) % 8) + 8
            let nextIndex = ((i + 1) % 8) + 8
            connections.append(prevIndex)
            connections.append(nextIndex)
            
            // Если это узел на радиальной линии (0, 2, 4, 6), соединяем с внешним кольцом
            if i % 2 == 0 {
                connections.append(i)  // Соединение с внешним кольцом
                connections.append(16 + i)  // Соединение с внутренним кольцом
            }
            
            initialNodes.append(MillNode(id: 8 + i, position: CGPoint(x: x, y: y), connections: connections))
        }
        
        // Формируем внутреннее кольцо (8 узлов)
        let innerRadius: CGFloat = 50
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let x = cos(angle) * innerRadius
            let y = sin(angle) * innerRadius
            
            // Определяем соединения для внутреннего кольца
            var connections: [Int] = []
            
            // Соединение с соседями в кольце
            let prevIndex = ((i - 1 + 8) % 8) + 16
            let nextIndex = ((i + 1) % 8) + 16
            connections.append(prevIndex)
            connections.append(nextIndex)
            
            // Если это узел на радиальной линии (0, 2, 4, 6), соединяем с средним кольцом
            if i % 2 == 0 {
                connections.append(8 + i)  // Соединение с средним кольцом
            }
            
            initialNodes.append(MillNode(id: 16 + i, position: CGPoint(x: x, y: y), connections: connections))
        }
        
        self.nodes = initialNodes
        
        // Определение линий для формирования мельниц
        var millLines: [Set<Int>] = []
        
        // Мельницы во внешнем кольце
        millLines.append([0, 1, 2])
        millLines.append([2, 3, 4])
        millLines.append([4, 5, 6])
        millLines.append([6, 7, 0])
        
        // Мельницы в среднем кольце
        millLines.append([8, 9, 10])
        millLines.append([10, 11, 12])
        millLines.append([12, 13, 14])
        millLines.append([14, 15, 8])
        
        // Мельницы во внутреннем кольце
        millLines.append([16, 17, 18])
        millLines.append([18, 19, 20])
        millLines.append([20, 21, 22])
        millLines.append([22, 23, 16])
        
        // Радиальные мельницы
        millLines.append([0, 8, 16])
        millLines.append([2, 10, 18])
        millLines.append([4, 12, 20])
        millLines.append([6, 14, 22])
        
        self.millLines = millLines
    }
    
    // Получение узла по его идентификатору
    func getNode(id: Int) -> MillNode? {
        return nodes.first(where: { $0.id == id })
    }
    
    // Проверка наличия мельницы у игрока
    func checkForMill(at nodeId: Int, for player: MillPlayerType) -> Bool {
        // Получаем все узлы с фишками данного игрока
        let playerNodeIds = nodes
            .filter { $0.piece?.player == player }
            .map { $0.id }
        
        for line in millLines {
            if line.contains(nodeId) && line.isSubset(of: Set(playerNodeIds)) {
                return true
            }
        }
        
        return false
    }
    
    // Получение всех мельниц для определенного игрока
    func getAllMills(for player: MillPlayerType) -> [Set<Int>] {
        let playerNodeIds = Set(nodes
            .filter { $0.piece?.player == player }
            .map { $0.id })
        
        return millLines.filter { line in
            line.isSubset(of: playerNodeIds)
        }
    }
    
    // Проверка, можно ли перемещаться между двумя узлами
    func canMove(from sourceId: Int, to destinationId: Int) -> Bool {
        guard let sourceNode = getNode(id: sourceId) else { return false }
        return sourceNode.connections.contains(destinationId)
    }
    
    // Получение доступных ходов для узла
    func getAvailableMoves(for nodeId: Int) -> [Int] {
        guard let node = getNode(id: nodeId) else { return [] }
        
        return node.connections.filter { connectionId in
            if let connectedNode = getNode(id: connectionId) {
                return connectedNode.piece == nil
            }
            return false
        }
    }
    
    // Получение всех пустых узлов
    func getEmptyNodes() -> [MillNode] {
        return nodes.filter { $0.piece == nil }
    }
    
    // Модифицирующий метод для обновления узла
    func updateNode(id: Int, piece: MillPiece?) {
        if let index = nodes.firstIndex(where: { $0.id == id }) {
            nodes[index].piece = piece
        }
    }
    
    // Модифицирующий метод для выделения узла
    func highlightNode(id: Int, highlighted: Bool) {
        if let index = nodes.firstIndex(where: { $0.id == id }) {
            nodes[index].isHighlighted = highlighted
        }
    }
    
    // Сброс всех выделений
    func resetHighlights() {
        for i in 0..<nodes.count {
            nodes[i].isHighlighted = false
        }
    }
    
    // Метод для валидации связей (для отладки)
    func validateConnections() {
        for node in nodes {
            print("Node \(node.id) connects to: \(node.connections)")
            
            // Проверяем, что все связи двунаправленные
            for connectionId in node.connections {
                if let connectedNode = getNode(id: connectionId) {
                    if !connectedNode.connections.contains(node.id) {
                        print("WARNING: One-way connection found! Node \(node.id) -> \(connectionId)")
                    }
                } else {
                    print("ERROR: Invalid connection! Node \(node.id) -> \(connectionId)")
                }
            }
        }
    }
}

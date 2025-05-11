//
//  MillGame.swift
//  GoldenMoon

import Combine
import SwiftUI

enum MillGamePhase: Int, Codable {
    case placement = 0
    case movement = 1
    case jump = 2  // Теперь это будет определяться индивидуально для каждого игрока
}

enum MillGameMode: Int, Codable {
    case tutorial = 0
    case twoPlayers = 1
    case vsAI = 2
}

class MillGame: ObservableObject {
    // Изменен тип board чтобы поддерживать реактивность
    @Published var board: MillBoard = MillBoard()
    @Published var currentPlayer: MillPlayerType = .player1
    @Published var selectedNodeId: Int?  // Добавлено это свойство
    @Published var gameMode: MillGameMode
    @Published var gameOver: Bool = false
    @Published var winner: MillPlayerType?
    @Published var mustRemovePiece: Bool = false
    @Published var lastMillFormedAt: Int?
    
    // Количество фишек для каждого игрока
    @Published var player1Pieces: Int = 9
    @Published var player2Pieces: Int = 9
    
    // Количество размещенных фишек
    @Published var player1PlacedPieces: Int = 0
    @Published var player2PlacedPieces: Int = 0
    
    // Флаг для отслеживания, была ли сформирована мельница
    @Published var millFormed: Bool = false
    
    // Добавляем канцеляции для отслеживания изменений в board
    private var boardCancellable: AnyCancellable?
    
    init(gameMode: MillGameMode = .twoPlayers) {
        self.gameMode = gameMode
        
        // Добавляем наблюдение за изменениями в board.nodes
        self.boardCancellable = self.board.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    // MARK: - Helper Methods
    
    // Определяем фазу игры для конкретного игрока
    func getPhaseForPlayer(_ player: MillPlayerType) -> MillGamePhase {
        // Если еще не все фишки размещены
        if !isAllPiecesPlaced() {
            return .placement
        }
        
        // Если у игрока осталось 3 фишки, он может прыгать
        let pieces = player == .player1 ? player1Pieces : player2Pieces
        if pieces <= 3 {
            return .jump
        }
        
        // Иначе обычное движение
        return .movement
    }
    
    // Проверяем, размещены ли все фишки
    func isAllPiecesPlaced() -> Bool {
        return player1PlacedPieces >= 9 && player2PlacedPieces >= 9
    }
    
    // MARK: - Game Logic
    
    func placePiece(at nodeId: Int) {
        // Всегда выполняем на основном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !self.mustRemovePiece else { return }
            guard let node = self.board.getNode(id: nodeId), node.piece == nil else { return }
            
            // В фазе расстановки фишек
            let currentPhase = self.getPhaseForPlayer(self.currentPlayer)
            if currentPhase == .placement {
                // Размещаем фишку текущего игрока
                let piece = MillPiece(player: self.currentPlayer)
                self.board.updateNode(id: nodeId, piece: piece)
                
                // Увеличиваем счетчик размещенных фишек
                if self.currentPlayer == .player1 {
                    self.player1PlacedPieces += 1
                } else {
                    self.player2PlacedPieces += 1
                }
                
                // Проверяем, сформировалась ли мельница
                self.millFormed = self.board.checkForMill(at: nodeId, for: self.currentPlayer)
                
                if self.millFormed {
                    self.mustRemovePiece = true
                    self.lastMillFormedAt = nodeId
                    
                    // Если это AI и нужно удалить фишку, вызываем AI ход
                    if self.gameMode == .vsAI && self.currentPlayer == .player2 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.makeAIMove()
                        }
                    }
                } else {
                    // Если не сформировалась мельница, переходим к следующему игроку
                    self.switchPlayer()
                }
            }
        }
    }
    
    func selectPiece(at nodeId: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !self.mustRemovePiece else { return }
            guard let node = self.board.getNode(id: nodeId),
                  let piece = node.piece,
                  piece.player == self.currentPlayer else { return }
            
            // Сбрасываем предыдущие подсветки
            self.board.resetHighlights()
            
            // Если эта фишка уже выбрана, отменяем выбор
            if self.selectedNodeId == nodeId {
                self.selectedNodeId = nil
                return
            }
            
            // Определяем доступные ходы
            var availableMoves: [Int] = []
            
            let currentPhase = self.getPhaseForPlayer(self.currentPlayer)
            if currentPhase == .movement {
                availableMoves = self.board.getAvailableMoves(for: nodeId)
            } else if currentPhase == .jump {
                // В фазе прыжков можно прыгать на любую пустую точку
                availableMoves = self.board.getEmptyNodes().map { $0.id }
            }
            
            // Выделяем узел только если есть доступные ходы
            if !availableMoves.isEmpty {
                self.selectedNodeId = nodeId
                
                // Выделяем доступные узлы
                for moveId in availableMoves {
                    self.board.highlightNode(id: moveId, highlighted: true)
                }
            }
        }
    }
    
    func movePiece(from sourceId: Int, to destinationId: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !self.mustRemovePiece else { return }
            guard let sourceNode = self.board.getNode(id: sourceId),
                  let destinationNode = self.board.getNode(id: destinationId),
                  let piece = sourceNode.piece,
                  piece.player == self.currentPlayer,
                  destinationNode.piece == nil else { return }
            
            // Проверяем, можно ли двигаться между этими узлами
            let currentPhase = self.getPhaseForPlayer(self.currentPlayer)
            if currentPhase == .movement && !self.board.canMove(from: sourceId, to: destinationId) {
                return
            }
            
            // Перемещаем фишку
            self.board.updateNode(id: sourceId, piece: nil)
            self.board.updateNode(id: destinationId, piece: piece)
            self.board.resetHighlights()
            self.selectedNodeId = nil
            
            // Проверяем, сформировалась ли мельница
            self.millFormed = self.board.checkForMill(at: destinationId, for: self.currentPlayer)
            
            if self.millFormed {
                self.mustRemovePiece = true
                self.lastMillFormedAt = destinationId
                
                // Если это AI и нужно удалить фишку, вызываем AI ход
                if self.gameMode == .vsAI && self.currentPlayer == .player2 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.makeAIMove()
                    }
                }
            } else {
                // Если не сформировалась мельница, переходим к следующему игроку
                self.switchPlayer()
            }
            
            // Проверяем условия завершения игры
            self.checkGameOver()
        }
    }
    
    func removePiece(at nodeId: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.mustRemovePiece else { return }
            guard let node = self.board.getNode(id: nodeId),
                  let piece = node.piece,
                  piece.player == self.currentPlayer.opponent else { return }
            
            // Проверяем, можно ли удалить эту фишку
            let opponentMills = self.board.getAllMills(for: self.currentPlayer.opponent)
            let isInMill = opponentMills.contains { mill in mill.contains(nodeId) }
            
            // Если фишка в мельнице, можно удалить только если все фишки противника в мельницах
            if isInMill {
                let allOpponentPieces = self.board.nodes.filter { $0.piece?.player == self.currentPlayer.opponent }
                let allInMills = allOpponentPieces.allSatisfy { node in
                    opponentMills.contains { mill in mill.contains(node.id) }
                }
                
                if !allInMills {
                    return // Нельзя удалить фишку из мельницы, если есть свободные фишки
                }
            }
            
            // Удаляем фишку
            self.board.updateNode(id: nodeId, piece: nil)
            self.mustRemovePiece = false
            self.lastMillFormedAt = nil
            
            // Уменьшаем счетчик фишек противника
            if self.currentPlayer == .player1 {
                self.player2Pieces -= 1
            } else {
                self.player1Pieces -= 1
            }
            
            // Переходим к следующему игроку
            self.switchPlayer()
            
            // Проверяем условия завершения игры
            self.checkGameOver()
        }
    }
    
    private func switchPlayer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentPlayer = self.currentPlayer.opponent
            self.selectedNodeId = nil
            self.board.resetHighlights()
        }
    }
    
    private func checkGameOver() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Игра заканчивается, если у игрока меньше 3 фишек
            if self.player1Pieces < 3 {
                self.gameOver = true
                self.winner = .player2
                return
            }
            
            if self.player2Pieces < 3 {
                self.gameOver = true
                self.winner = .player1
                return
            }
            
            // Игра заканчивается, если у игрока нет доступных ходов
            if self.isAllPiecesPlaced() {
                var hasAvailableMoves = false
                
                let playerNodes = self.board.nodes.filter { node in
                    node.piece?.player == self.currentPlayer
                }
                
                let currentPhase = self.getPhaseForPlayer(self.currentPlayer)
                
                for node in playerNodes {
                    if currentPhase == .jump {
                        // В фазе прыжков, если есть хотя бы один пустой узел
                        if !self.board.getEmptyNodes().isEmpty {
                            hasAvailableMoves = true
                            break
                        }
                    } else {
                        // В фазе движения, если есть хотя бы один доступный ход
                        if !self.board.getAvailableMoves(for: node.id).isEmpty {
                            hasAvailableMoves = true
                            break
                        }
                    }
                }
                
                if !hasAvailableMoves {
                    self.gameOver = true
                    self.winner = self.currentPlayer.opponent
                }
            }
        }
    }
    
    // MARK: - AI Logic
    
    func makeAIMove() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.gameMode == .vsAI && self.currentPlayer == .player2 && !self.gameOver else { return }
            
            if self.mustRemovePiece {
                self.makeAIRemovePiece()
            } else {
                let currentPhase = self.getPhaseForPlayer(self.currentPlayer)
                switch currentPhase {
                case .placement:
                    self.makeAIPlacement()
                case .movement:
                    self.makeAIMovement()
                case .jump:
                    self.makeAIJump()
                }
            }
        }
    }
    
    private func makeAIPlacement() {
        let emptyNodes = board.getEmptyNodes()
        
        // Стратегия AI для размещения:
        // 1. Попытаться завершить свою мельницу
        // 2. Блокировать мельницу противника
        // 3. Разместить для создания потенциальной мельницы
        // 4. Случайное размещение
        
        // Проверяем, можем ли завершить мельницу
        for node in emptyNodes {
            // Временно размещаем фишку
            board.updateNode(id: node.id, piece: MillPiece(player: .player2))
            if board.checkForMill(at: node.id, for: .player2) {
                // Возвращаем состояние и делаем ход
                board.updateNode(id: node.id, piece: nil)
                placePiece(at: node.id)
                return
            }
            // Возвращаем состояние
            board.updateNode(id: node.id, piece: nil)
        }
        
        // Проверяем, нужно ли блокировать мельницу противника
        for node in emptyNodes {
            // Временно размещаем фишку противника
            board.updateNode(id: node.id, piece: MillPiece(player: .player1))
            if board.checkForMill(at: node.id, for: .player1) {
                // Возвращаем состояние и блокируем
                board.updateNode(id: node.id, piece: nil)
                placePiece(at: node.id)
                return
            }
            // Возвращаем состояние
            board.updateNode(id: node.id, piece: nil)
        }
        
        // Пытаемся создать потенциальную мельницу
        var bestNode: MillNode?
        var maxPotential = 0
        
        for node in emptyNodes {
            // Подсчитываем количество потенциальных мельниц для этой позиции
            var potential = 0
            for line in board.millLines {
                if line.contains(node.id) {
                    let aiPiecesInLine = line.filter { nodeId in
                        board.getNode(id: nodeId)?.piece?.player == .player2
                    }.count
                    
                    let emptyInLine = line.filter { nodeId in
                        board.getNode(id: nodeId)?.piece == nil
                    }.count
                    
                    // Если в линии есть 1 наша фишка и 2 пустых места
                    if aiPiecesInLine == 1 && emptyInLine == 2 {
                        potential += 1
                    }
                }
            }
            
            if potential > maxPotential {
                maxPotential = potential
                bestNode = node
            }
        }
        
        if let node = bestNode {
            placePiece(at: node.id)
        } else if let randomNode = emptyNodes.randomElement() {
            placePiece(at: randomNode.id)
        }
    }
    
    private func makeAIMovement() {
        let aiPieces = board.nodes.filter { node in
            node.piece?.player == .player2
        }
        
        // Стратегия AI для движения:
        // 1. Попытаться создать мельницу
        // 2. Блокировать мельницу противника
        // 3. Улучшить позицию
        
        // Проверяем, можем ли создать мельницу
        for piece in aiPieces {
            let availableMoves = board.getAvailableMoves(for: piece.id)
            for moveId in availableMoves {
                // Временно перемещаем фишку
                let originalPiece = piece.piece
                board.updateNode(id: piece.id, piece: nil)
                board.updateNode(id: moveId, piece: originalPiece)
                
                if board.checkForMill(at: moveId, for: .player2) {
                    // Возвращаем состояние и делаем ход
                    board.updateNode(id: moveId, piece: nil)
                    board.updateNode(id: piece.id, piece: originalPiece)
                    movePiece(from: piece.id, to: moveId)
                    return
                }
                
                // Возвращаем состояние
                board.updateNode(id: moveId, piece: nil)
                board.updateNode(id: piece.id, piece: originalPiece)
            }
        }
        
        // Проверяем, нужно ли блокировать
        for piece in aiPieces {
            let availableMoves = board.getAvailableMoves(for: piece.id)
            for moveId in availableMoves {
                // Проверяем, может ли противник создать мельницу в этой позиции
                board.updateNode(id: moveId, piece: MillPiece(player: .player1))
                if board.checkForMill(at: moveId, for: .player1) {
                    board.updateNode(id: moveId, piece: nil)
                    movePiece(from: piece.id, to: moveId)
                    return
                }
                board.updateNode(id: moveId, piece: nil)
            }
        }
        
        // Делаем лучший доступный ход
        var bestMove: (from: Int, to: Int)?
        var bestScore = -1
        
        for piece in aiPieces {
            let availableMoves = board.getAvailableMoves(for: piece.id)
            for moveId in availableMoves {
                var score = 0
                
                // Оцениваем позицию
                for line in board.millLines {
                    if line.contains(moveId) {
                        let aiPiecesInLine = line.filter { nodeId in
                            board.getNode(id: nodeId)?.piece?.player == .player2
                        }.count
                        score += aiPiecesInLine
                    }
                }
                
                if score > bestScore {
                    bestScore = score
                    bestMove = (from: piece.id, to: moveId)
                }
            }
        }
        
        if let move = bestMove {
            movePiece(from: move.from, to: move.to)
        } else {
            // Делаем случайный ход
            for piece in aiPieces.shuffled() {
                let availableMoves = board.getAvailableMoves(for: piece.id)
                if let randomMove = availableMoves.randomElement() {
                    movePiece(from: piece.id, to: randomMove)
                    return
                }
            }
        }
    }
    
    private func makeAIJump() {
        let aiPieces = board.nodes.filter { node in
            node.piece?.player == .player2
        }
        let emptyNodes = board.getEmptyNodes()
        
        // В фазе прыжков, AI пытается создать мельницу или улучшить позицию
        var bestJump: (from: Int, to: Int)?
        var bestScore = -1
        
        for piece in aiPieces {
            for emptyNode in emptyNodes {
                // Временно перемещаем фишку
                let originalPiece = piece.piece
                board.updateNode(id: piece.id, piece: nil)
                board.updateNode(id: emptyNode.id, piece: originalPiece)
                
                // Проверяем, создается ли мельница
                if board.checkForMill(at: emptyNode.id, for: .player2) {
                    // Возвращаем состояние и делаем ход
                    board.updateNode(id: emptyNode.id, piece: nil)
                    board.updateNode(id: piece.id, piece: originalPiece)
                    movePiece(from: piece.id, to: emptyNode.id)
                    return
                }
                
                // Оцениваем позицию
                var score = 0
                for line in board.millLines {
                    if line.contains(emptyNode.id) {
                        let aiPiecesInLine = line.filter { nodeId in
                            let node = board.getNode(id: nodeId)
                            return (nodeId == emptyNode.id && originalPiece?.player == .player2) ||
                                   (nodeId != emptyNode.id && node?.piece?.player == .player2)
                        }.count
                        score += aiPiecesInLine
                    }
                }
                
                // Возвращаем состояние
                board.updateNode(id: emptyNode.id, piece: nil)
                board.updateNode(id: piece.id, piece: originalPiece)
                
                if score > bestScore {
                    bestScore = score
                    bestJump = (from: piece.id, to: emptyNode.id)
                }
            }
        }
        
        if let jump = bestJump {
            movePiece(from: jump.from, to: jump.to)
        } else if let randomPiece = aiPieces.randomElement(),
                  let randomEmpty = emptyNodes.randomElement() {
            movePiece(from: randomPiece.id, to: randomEmpty.id)
        }
    }
    
    private func makeAIRemovePiece() {
        let opponentPieces = board.nodes.filter { node in
            node.piece?.player == .player1
        }
        
        // Стратегия для удаления фишек:
        // 1. Удалить фишку, которая может создать мельницу
        // 2. Удалить фишку из стратегически важной позиции
        // 3. Удалить случайную фишку (не из мельницы)
        
        let opponentMills = board.getAllMills(for: .player1)
        let piecesNotInMill = opponentPieces.filter { node in
            !opponentMills.contains { mill in mill.contains(node.id) }
        }
        
        // Если есть фишки не в мельницах
        if !piecesNotInMill.isEmpty {
            var bestPiece: MillNode?
            var maxThreat = 0
            
            for piece in piecesNotInMill {
                // Оцениваем угрозу от этой фишки
                var threat = 0
                
                // Проверяем, сколько потенциальных мельниц может создать эта фишка
                for line in board.millLines {
                    if line.contains(piece.id) {
                        let playerPiecesInLine = line.filter { nodeId in
                            board.getNode(id: nodeId)?.piece?.player == .player1
                        }.count
                        
                        if playerPiecesInLine == 2 {
                            threat += 2  // Эта фишка близка к созданию мельницы
                        } else if playerPiecesInLine == 1 {
                            threat += 1  // Эта фишка участвует в потенциальной мельнице
                        }
                    }
                }
                
                if threat > maxThreat {
                    maxThreat = threat
                    bestPiece = piece
                }
            }
            
            if let piece = bestPiece {
                removePiece(at: piece.id)
                return
            }
            
            // Если не нашли стратегически важную фишку, удаляем случайную
            if let randomPiece = piecesNotInMill.randomElement() {
                removePiece(at: randomPiece.id)
                return
            }
        }
        
        // Если все фишки в мельницах, удаляем случайную
        if let randomPiece = opponentPieces.randomElement() {
            removePiece(at: randomPiece.id)
        }
    }
    
    // MARK: - Game State
    
    func resetGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.board = MillBoard()
            self.currentPlayer = .player1
            self.selectedNodeId = nil  // Добавлено сброс selectedNodeId
            self.gameOver = false
            self.winner = nil
            self.mustRemovePiece = false
            self.lastMillFormedAt = nil
            self.player1Pieces = 9
            self.player2Pieces = 9
            self.player1PlacedPieces = 0
            self.player2PlacedPieces = 0
            self.millFormed = false
            
            // Обновляем наблюдение за изменениями board после ее пересоздания
            self.boardCancellable = self.board.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
    }
}

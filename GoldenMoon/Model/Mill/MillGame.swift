//
//  MillGame.swift
//  GoldenMoon

import Combine
import SwiftUI

enum MillGamePhase: Int, Codable {
    case placement = 0
    case movement = 1
    case jump = 2
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
    @Published var phase: MillGamePhase = .placement
    @Published var selectedNodeId: Int?
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
    
    // MARK: - Game Logic
    
    func placePiece(at nodeId: Int) {
        // Всегда выполняем на основном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !self.mustRemovePiece else { return }
            guard let node = self.board.getNode(id: nodeId), node.piece == nil else { return }
            
            // В фазе расстановки фишек
            if self.phase == .placement {
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
                } else {
                    // Если не сформировалась мельница, переходим к следующему игроку
                    self.switchPlayer()
                }
                
                // Проверяем, нужно ли переходить к следующей фазе
                self.checkPhaseTransition()
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
            
            self.board.resetHighlights()
            
            // Определяем доступные ходы
            var availableMoves: [Int] = []
            
            if self.phase == .movement {
                availableMoves = self.board.getAvailableMoves(for: nodeId)
            } else if self.phase == .jump {
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
            if self.phase == .movement && !self.board.canMove(from: sourceId, to: destinationId) {
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
            
            // Проверяем условия завершения игры и перехода к фазе прыжков
            self.checkPhaseTransition()
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
    
    private func checkPhaseTransition() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Если оба игрока разместили все фишки, переходим к фазе движения
            if self.phase == .placement && self.player1PlacedPieces >= 9 && self.player2PlacedPieces >= 9 {
                self.phase = .movement
            }
            
            // Проверяем, нужно ли перейти в фазу прыжков для текущего игрока
            if self.phase == .movement {
                let playerPieces = self.currentPlayer == .player1 ? self.player1Pieces : self.player2Pieces
                if playerPieces <= 3 {
                    self.phase = .jump
                }
            }
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
            if self.phase != .placement {
                var hasAvailableMoves = false
                
                let playerNodes = self.board.nodes.filter { node in
                    node.piece?.player == self.currentPlayer
                }
                
                for node in playerNodes {
                    if self.phase == .jump {
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
                switch self.phase {
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
        if let randomNode = emptyNodes.randomElement() {
            placePiece(at: randomNode.id)
        }
    }
    
    private func makeAIMovement() {
        let aiPieces = board.nodes.filter { node in
            node.piece?.player == .player2
        }
        
        // Перебираем все фишки AI
        for piece in aiPieces.shuffled() {
            let availableMoves = board.getAvailableMoves(for: piece.id)
            if let randomMove = availableMoves.randomElement() {
                movePiece(from: piece.id, to: randomMove)
                return
            }
        }
    }
    
    private func makeAIJump() {
        let aiPieces = board.nodes.filter { node in
            node.piece?.player == .player2
        }
        let emptyNodes = board.getEmptyNodes()
        
        if let randomPiece = aiPieces.randomElement(),
           let randomEmpty = emptyNodes.randomElement() {
            movePiece(from: randomPiece.id, to: randomEmpty.id)
        }
    }
    
    private func makeAIRemovePiece() {
        let opponentPieces = board.nodes.filter { node in
            node.piece?.player == .player1
        }
        
        // Сначала пытаемся найти фишки вне мельниц
        let opponentMills = board.getAllMills(for: .player1)
        let piecesNotInMill = opponentPieces.filter { node in
            !opponentMills.contains { mill in mill.contains(node.id) }
        }
        
        if let randomPiece = piecesNotInMill.randomElement() {
            removePiece(at: randomPiece.id)
        } else if let randomPiece = opponentPieces.randomElement() {
            removePiece(at: randomPiece.id)
        }
    }
    
    // MARK: - Game State
    
    func resetGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.board = MillBoard()
            self.currentPlayer = .player1
            self.phase = .placement
            self.selectedNodeId = nil
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

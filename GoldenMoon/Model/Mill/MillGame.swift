//
//  MillGame.swift
//  GoldenMoon

import Foundation

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
    @Published var board: MillBoard
    @Published var currentPlayer: MillPlayerType = .player1
    @Published var phase: MillGamePhase = .placement
    @Published var selectedNodeId: Int?
    @Published var gameMode: MillGameMode
    @Published var gameOver: Bool = false
    @Published var winner: MillPlayerType?
    @Published var mustRemovePiece: Bool = false
    @Published var lastMillFormedAt: Int?
    
    // Количество фишек для каждого игрока
    var player1Pieces: Int = 9
    var player2Pieces: Int = 9
    
    // Количество размещенных фишек
    var player1PlacedPieces: Int = 0
    var player2PlacedPieces: Int = 0
    
    // Флаг для отслеживания, была ли сформирована мельница
    var millFormed: Bool = false
    
    init(gameMode: MillGameMode = .twoPlayers) {
        self.board = MillBoard()
        self.gameMode = gameMode
    }
    
    // MARK: - Game Logic
    
    func placePiece(at nodeId: Int) {
        guard !mustRemovePiece else { return }
        guard let node = board.getNode(id: nodeId), node.piece == nil else { return }
        
        // В фазе расстановки фишек
        if phase == .placement {
            // Размещаем фишку текущего игрока
            let piece = MillPiece(player: currentPlayer)
            board.updateNode(id: nodeId, piece: piece)
            
            // Увеличиваем счетчик размещенных фишек
            if currentPlayer == .player1 {
                player1PlacedPieces += 1
            } else {
                player2PlacedPieces += 1
            }
            
            // Проверяем, сформировалась ли мельница
            millFormed = board.checkForMill(at: nodeId, for: currentPlayer)
            
            if millFormed {
                mustRemovePiece = true
                lastMillFormedAt = nodeId
            } else {
                // Если не сформировалась мельница, переходим к следующему игроку
                switchPlayer()
            }
            
            // Проверяем, нужно ли переходить к следующей фазе
            checkPhaseTransition()
        }
    }
    
    func selectPiece(at nodeId: Int) {
        guard !mustRemovePiece else { return }
        guard let node = board.getNode(id: nodeId),
              let piece = node.piece,
              piece.player == currentPlayer else { return }
        
        board.resetHighlights()
        
        // Определяем доступные ходы
        var availableMoves: [Int] = []
        
        if phase == .movement {
            availableMoves = board.getAvailableMoves(for: nodeId)
        } else if phase == .jump {
            // В фазе прыжков можно прыгать на любую пустую точку
            availableMoves = board.getEmptyNodes().map { $0.id }
        }
        
        // Выделяем узел только если есть доступные ходы
        if !availableMoves.isEmpty {
            selectedNodeId = nodeId
            
            // Выделяем доступные узлы
            for moveId in availableMoves {
                board.highlightNode(id: moveId, highlighted: true)
            }
        }
    }
    
    func movePiece(from sourceId: Int, to destinationId: Int) {
        guard !mustRemovePiece else { return }
        guard let sourceNode = board.getNode(id: sourceId),
              let destinationNode = board.getNode(id: destinationId),
              let piece = sourceNode.piece,
              piece.player == currentPlayer,
              destinationNode.piece == nil else { return }
        
        // Проверяем, можно ли двигаться между этими узлами
        if phase == .movement && !board.canMove(from: sourceId, to: destinationId) {
            return
        }
        
        // Перемещаем фишку
        board.updateNode(id: sourceId, piece: nil)
        board.updateNode(id: destinationId, piece: piece)
        board.resetHighlights()
        selectedNodeId = nil
        
        // Проверяем, сформировалась ли мельница
        millFormed = board.checkForMill(at: destinationId, for: currentPlayer)
        
        if millFormed {
            mustRemovePiece = true
            lastMillFormedAt = destinationId
        } else {
            // Если не сформировалась мельница, переходим к следующему игроку
            switchPlayer()
        }
        
        // Проверяем условия завершения игры
        checkGameOver()
    }
    
    func removePiece(at nodeId: Int) {
        guard mustRemovePiece else { return }
        guard let node = board.getNode(id: nodeId),
              let piece = node.piece,
              piece.player == currentPlayer.opponent else { return }
        
        // Проверяем, можно ли удалить эту фишку
        let opponentMills = board.getAllMills(for: currentPlayer.opponent)
        let isInMill = opponentMills.contains { mill in mill.contains(nodeId) }
        
        // Если фишка в мельнице, можно удалить только если все фишки противника в мельницах
        if isInMill {
            let allOpponentPieces = board.nodes.filter { $0.piece?.player == currentPlayer.opponent }
            let allInMills = allOpponentPieces.allSatisfy { node in
                opponentMills.contains { mill in mill.contains(node.id) }
            }
            
            if !allInMills {
                return // Нельзя удалить фишку из мельницы, если есть свободные фишки
            }
        }
        
        // Удаляем фишку
        board.updateNode(id: nodeId, piece: nil)
        mustRemovePiece = false
        lastMillFormedAt = nil
        
        // Уменьшаем счетчик фишек противника
        if currentPlayer == .player1 {
            player2Pieces -= 1
        } else {
            player1Pieces -= 1
        }
        
        // Переходим к следующему игроку
        switchPlayer()
        
        // Проверяем условия завершения игры и перехода к фазе прыжков
        checkPhaseTransition()
        checkGameOver()
    }
    
    private func switchPlayer() {
        currentPlayer = currentPlayer.opponent
        selectedNodeId = nil
        board.resetHighlights()
    }
    
    private func checkPhaseTransition() {
        // Если оба игрока разместили все фишки, переходим к фазе движения
        if phase == .placement && player1PlacedPieces >= 9 && player2PlacedPieces >= 9 {
            phase = .movement
        }
        
        // Проверяем, нужно ли перейти в фазу прыжков для текущего игрока
        if phase == .movement {
            let playerPieces = currentPlayer == .player1 ? player1Pieces : player2Pieces
            if playerPieces <= 3 {
                phase = .jump
            }
        }
    }
    
    private func checkGameOver() {
        // Игра заканчивается, если у игрока меньше 3 фишек
        if player1Pieces < 3 {
            gameOver = true
            winner = .player2
            return
        }
        
        if player2Pieces < 3 {
            gameOver = true
            winner = .player1
            return
        }
        
        // Игра заканчивается, если у игрока нет доступных ходов
        if phase != .placement {
            var hasAvailableMoves = false
            
            let playerNodes = board.nodes.filter { node in
                node.piece?.player == currentPlayer
            }
            
            for node in playerNodes {
                if phase == .jump {
                    // В фазе прыжков, если есть хотя бы один пустой узел
                    if !board.getEmptyNodes().isEmpty {
                        hasAvailableMoves = true
                        break
                    }
                } else {
                    // В фазе движения, если есть хотя бы один доступный ход
                    if !board.getAvailableMoves(for: node.id).isEmpty {
                        hasAvailableMoves = true
                        break
                    }
                }
            }
            
            if !hasAvailableMoves {
                gameOver = true
                winner = currentPlayer.opponent
            }
        }
    }
    
    // MARK: - AI Logic
    
    func makeAIMove() {
        guard gameMode == .vsAI && currentPlayer == .player2 && !gameOver else { return }
        
        if mustRemovePiece {
            makeAIRemovePiece()
        } else {
            switch phase {
            case .placement:
                makeAIPlacement()
            case .movement:
                makeAIMovement()
            case .jump:
                makeAIJump()
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
        board = MillBoard()
        currentPlayer = .player1
        phase = .placement
        selectedNodeId = nil
        gameOver = false
        winner = nil
        mustRemovePiece = false
        lastMillFormedAt = nil
        player1Pieces = 9
        player2Pieces = 9
        player1PlacedPieces = 0
        player2PlacedPieces = 0
        millFormed = false
    }
}

//
//  MillGameViewModel.swift
//  GoldenMoon

import SwiftUI
import Combine

class MillGameViewModel: ObservableObject {
    @ObservedObject var game: MillGame
    @Published var showVictoryOverlay: Bool = false
    @Published var showDefeatOverlay: Bool = false
    @Published var isPaused: Bool = false
    @Published var tutorialStep: Int = 0
    @Published var tutorialCompleted: Bool = false
    
    weak var appViewModel: AppViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init(gameMode: MillGameMode = .twoPlayers) {
        self.game = MillGame(gameMode: gameMode)
        setupBindings()
    }
    
    private func setupBindings() {
        // Наблюдаем за изменениями в игре
        game.$gameOver
            .receive(on: RunLoop.main)
            .sink { [weak self] gameOver in
                guard let self = self, gameOver else { return }
                self.handleGameOver()
            }
            .store(in: &cancellables)
        
        // В режиме игры против ИИ, делаем ход ИИ после хода игрока
        game.$currentPlayer
            .receive(on: RunLoop.main)
            .sink { [weak self] player in
                guard let self = self,
                      self.game.gameMode == .vsAI,
                      player == .player2,
                      !self.game.gameOver,
                      !self.game.mustRemovePiece || self.game.currentPlayer == .player2 else {
                    return
                }
                
                // Добавляем небольшую задержку, чтобы игрок успел увидеть свой ход
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.game.makeAIMove()
                }
            }
            .store(in: &cancellables)
            
        // Добавляем явное прослушивание objectWillChange
        game.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Game Controls
    
    func handleNodeTap(_ nodeId: Int) {
        // Всегда обрабатываем на основном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.game.gameMode == .tutorial {
                self.handleTutorialNodeTap(nodeId)
                return
            }
            
            if self.isPaused || self.game.gameOver {
                return
            }
            
            // Обрабатываем действие в зависимости от текущей фазы игры
            if self.game.mustRemovePiece {
                self.game.removePiece(at: nodeId)
            } else if self.game.phase == .placement {
                self.game.placePiece(at: nodeId)
            } else {
                // Фазы movement или jump
                if let selectedNodeId = self.game.selectedNodeId {
                    self.game.movePiece(from: selectedNodeId, to: nodeId)
                } else {
                    self.game.selectPiece(at: nodeId)
                }
            }
        }
    }
    
    func togglePause(_ paused: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isPaused = paused
        }
    }
    
    func pauseGame() {
        DispatchQueue.main.async { [weak self] in
            self?.isPaused = true
        }
    }
    
    func resumeGame() {
        DispatchQueue.main.async { [weak self] in
            self?.isPaused = false
        }
    }
    
    func resetGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.game.resetGame()
            self.showVictoryOverlay = false
            self.showDefeatOverlay = false
            self.isPaused = false
        }
    }
    
    // MARK: - Game State
    
    private func handleGameOver() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.game.gameMode == .tutorial {
                self.tutorialCompleted = true
                return
            }
            
            if let winner = self.game.winner {
                if self.game.gameMode == .vsAI {
                    if winner == .player1 {
                        self.showVictoryOverlay = true
                        self.appViewModel?.showVictory()
                    } else {
                        self.showDefeatOverlay = true
                        self.appViewModel?.showDefeat()
                    }
                } else {
                    // В режиме игры вдвоем просто показываем оверлей победы
                    self.showVictoryOverlay = true
                }
            }
        }
    }
    
    // MARK: - Tutorial Mode
    
    private func handleTutorialNodeTap(_ nodeId: Int) {
        // Всегда обрабатываем на основном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Логика для пошагового обучения
            switch self.tutorialStep {
            case 0: // Объяснение правил размещения фишек
                if self.game.phase == .placement && !self.game.mustRemovePiece {
                    self.game.placePiece(at: nodeId)
                    if self.game.millFormed {
                        self.tutorialStep = 1 // Переход к объяснению удаления фишек при формировании мельницы
                    }
                }
            case 1: // Объяснение удаления фишек при формировании мельницы
                if self.game.mustRemovePiece {
                    self.game.removePiece(at: nodeId)
                    self.tutorialStep = 2 // Переход к объяснению перемещения фишек
                }
            case 2: // Объяснение перемещения фишек
                if self.game.phase == .movement && !self.game.mustRemovePiece {
                    if self.game.selectedNodeId == nil {
                        self.game.selectPiece(at: nodeId)
                    } else {
                        self.game.movePiece(from: self.game.selectedNodeId!, to: nodeId)
                        self.tutorialStep = 3 // Переход к объяснению прыжков
                    }
                }
            case 3: // Объяснение прыжков (при 3 фишках)
                if self.game.phase == .jump && !self.game.mustRemovePiece {
                    if self.game.selectedNodeId == nil {
                        self.game.selectPiece(at: nodeId)
                    } else {
                        self.game.movePiece(from: self.game.selectedNodeId!, to: nodeId)
                        self.tutorialStep = 4 // Завершение обучения
                    }
                }
            case 4: // Завершение обучения
                self.tutorialCompleted = true
            default:
                break
            }
        }
    }
    
    // MARK: - Helper methods
    
    func getCurrentPlayerName() -> String {
        return game.currentPlayer == .player1 ? "Your Turn" : "Wait"
    }
    
    func getPhaseText() -> String {
        switch game.phase {
        case .placement:
            return "Place your pieces"
        case .movement:
            return "Move your pieces"
        case .jump:
            return "Jump Mode"
        }
    }
    
    func getActionText() -> String {
        if game.mustRemovePiece {
            return "Remove opponent's piece"
        }
        
        if game.phase == .placement {
            return "Place your piece"
        }
        
        if let _ = game.selectedNodeId {
            return "Select destination"
        } else {
            return "Select your piece"
        }
    }
    
    func getTutorialText() -> String {
        switch tutorialStep {
        case 0:
            return "Welcome to the tutorial! Place your pieces on the board to form a mill (3 in a row)."
        case 1:
            return "You formed a mill! Now you can remove an opponent's piece."
        case 2:
            return "Now let's learn how to move pieces. Select one of your pieces and move it along a line."
        case 3:
            return "When you have only 3 pieces left, you can jump to any empty spot. Try it now!"
        case 4:
            return "Congratulations! You've completed the tutorial."
        default:
            return ""
        }
    }
}

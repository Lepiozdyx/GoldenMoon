//
//  MillGameViewModel.swift
//  GoldenMoon

import SwiftUI
import Combine

class MillGameViewModel: ObservableObject {
    @Published var game: MillGame
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
            .sink { [weak self] gameOver in
                guard let self = self, gameOver else { return }
                self.handleGameOver()
            }
            .store(in: &cancellables)
        
        // В режиме игры против ИИ, делаем ход ИИ после хода игрока
        game.$currentPlayer
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
    }
    
    // MARK: - Game Controls
    
    func handleNodeTap(_ nodeId: Int) {
        if game.gameMode == .tutorial {
            handleTutorialNodeTap(nodeId)
            return
        }
        
        if isPaused || game.gameOver {
            return
        }
        
        // Обрабатываем действие в зависимости от текущей фазы игры
        if game.mustRemovePiece {
            game.removePiece(at: nodeId)
        } else if game.phase == .placement {
            game.placePiece(at: nodeId)
        } else {
            // Фазы movement или jump
            if let selectedNodeId = game.selectedNodeId {
                game.movePiece(from: selectedNodeId, to: nodeId)
            } else {
                game.selectPiece(at: nodeId)
            }
        }
    }
    
    func togglePause(_ paused: Bool) {
        isPaused = paused
    }
    
    func pauseGame() {
        isPaused = true
    }
    
    func resumeGame() {
        isPaused = false
    }
    
    func resetGame() {
        game.resetGame()
        showVictoryOverlay = false
        showDefeatOverlay = false
        isPaused = false
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
        // Логика для пошагового обучения
        switch tutorialStep {
        case 0: // Объяснение правил размещения фишек
            if game.phase == .placement && !game.mustRemovePiece {
                game.placePiece(at: nodeId)
                if game.millFormed {
                    tutorialStep = 1 // Переход к объяснению удаления фишек при формировании мельницы
                }
            }
        case 1: // Объяснение удаления фишек при формировании мельницы
            if game.mustRemovePiece {
                game.removePiece(at: nodeId)
                tutorialStep = 2 // Переход к объяснению перемещения фишек
            }
        case 2: // Объяснение перемещения фишек
            if game.phase == .movement && !game.mustRemovePiece {
                if game.selectedNodeId == nil {
                    game.selectPiece(at: nodeId)
                } else {
                    game.movePiece(from: game.selectedNodeId!, to: nodeId)
                    tutorialStep = 3 // Переход к объяснению прыжков
                }
            }
        case 3: // Объяснение прыжков (при 3 фишках)
            if game.phase == .jump && !game.mustRemovePiece {
                if game.selectedNodeId == nil {
                    game.selectPiece(at: nodeId)
                } else {
                    game.movePiece(from: game.selectedNodeId!, to: nodeId)
                    tutorialStep = 4 // Завершение обучения
                }
            }
        case 4: // Завершение обучения
            tutorialCompleted = true
        default:
            break
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

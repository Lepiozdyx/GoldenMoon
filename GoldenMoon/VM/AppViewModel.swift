//
//  AppViewModel.swift
//  GoldenMoon

import SwiftUI
import Combine

enum AppScreen {
    case menu
    case game
    case settings
}

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var millGameViewModel: MillGameViewModel?
    @Published var coins: Int = 0
    @Published var currentLevel: Int = 1
    
    // Данные для сохранения прогресса
    private var levelsCompleted: Int = 0
    private var millsFormed: Int = 0
    private var maxCompletedLevel: Int = 0
    
    // UserDefaults ключи
    private let coinsKey = "goldenMoon.coins"
    private let currentLevelKey = "goldenMoon.currentLevel"
    private let levelsCompletedKey = "goldenMoon.levelsCompleted"
    private let millsFormedKey = "goldenMoon.millsFormed"
    private let maxCompletedLevelKey = "goldenMoon.maxCompletedLevel"
    
    init() {
        // Загрузка сохраненных данных
        self.coins = UserDefaults.standard.integer(forKey: coinsKey)
        self.currentLevel = UserDefaults.standard.integer(forKey: currentLevelKey)
        self.levelsCompleted = UserDefaults.standard.integer(forKey: levelsCompletedKey)
        self.millsFormed = UserDefaults.standard.integer(forKey: millsFormedKey)
        self.maxCompletedLevel = UserDefaults.standard.integer(forKey: maxCompletedLevelKey)
        
        // Установка минимальных значений
        if self.currentLevel < 1 {
            self.currentLevel = 1
        }
    }
    
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }
    
    func startGame(mode: MillGameMode = .twoPlayers) {
        millGameViewModel = MillGameViewModel(gameMode: mode)
        millGameViewModel?.appViewModel = self
        navigateTo(.game)
    }
    
    func goToMenu() {
        millGameViewModel = nil
        navigateTo(.menu)
    }
    
    func showVictory() {
        // Базовая награда за победу
        let reward = 10
        coins += reward
        levelsCompleted += 1
        
        // Обновляем данные о максимальном пройденном уровне
        if currentLevel > maxCompletedLevel {
            maxCompletedLevel = currentLevel
        }
        
        // Обновляем статистику по мельницам
        if let gameVM = millGameViewModel {
            let millsInThisGame = gameVM.game.board.getAllMills(for: .player1).count
            millsFormed += millsInThisGame
        }
        
        // Сохраняем данные
        saveGameState()
    }
    
    func showDefeat() {
        // Можно добавить небольшую награду за попытку
        let consolationReward = 1
        coins += consolationReward
        saveGameState()
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
        saveGameState()
    }
    
    func goToNextLevel() {
        // Увеличиваем номер уровня
        currentLevel += 1
        
        // Сохраняем прогресс
        saveGameState()
        
        // Создаем новую игру с новым уровнем
        // Для игры "Мельница" мы можем добавить различные начальные конфигурации или усложнения
        // в зависимости от уровня, но для базовой реализации просто перезапускаем игру
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сбрасываем текущую игру и создаем новую
            let gameMode = self.millGameViewModel?.game.gameMode ?? .twoPlayers
            self.millGameViewModel = MillGameViewModel(gameMode: gameMode)
            self.millGameViewModel?.appViewModel = self
            
            // Увеличиваем сложность AI по мере прохождения уровней (если это режим против AI)
            if gameMode == .vsAI {
                // Здесь можно реализовать логику изменения сложности
                // В зависимости от уровня
            }
            
            // Обновляем UI чтобы отразить изменения
            self.objectWillChange.send()
        }
    }
    
    func restartLevel() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сбрасываем текущую игру, но не меняем уровень
            self.millGameViewModel?.resetGame()
            self.millGameViewModel?.resumeGame()
            
            // Обновляем UI
            self.objectWillChange.send()
        }
    }
    
    func saveGameState() {
        UserDefaults.standard.set(coins, forKey: coinsKey)
        UserDefaults.standard.set(currentLevel, forKey: currentLevelKey)
        UserDefaults.standard.set(levelsCompleted, forKey: levelsCompletedKey)
        UserDefaults.standard.set(millsFormed, forKey: millsFormedKey)
        UserDefaults.standard.set(maxCompletedLevel, forKey: maxCompletedLevelKey)
        UserDefaults.standard.synchronize()
    }
    
    func resetAllProgress() {
        coins = 0
        currentLevel = 1
        levelsCompleted = 0
        millsFormed = 0
        maxCompletedLevel = 0
        
        UserDefaults.standard.removeObject(forKey: coinsKey)
        UserDefaults.standard.removeObject(forKey: currentLevelKey)
        UserDefaults.standard.removeObject(forKey: levelsCompletedKey)
        UserDefaults.standard.removeObject(forKey: millsFormedKey)
        UserDefaults.standard.removeObject(forKey: maxCompletedLevelKey)
        UserDefaults.standard.synchronize()
    }
}

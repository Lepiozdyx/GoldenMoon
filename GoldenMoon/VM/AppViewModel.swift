//
//  AppViewModel.swift
//  GoldenMoon

import SwiftUI
import Combine

enum AppScreen {
    case menu
    case mode
    case game
    case settings
    case shop
    case achievements
    case reward
}

@MainActor
class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var millGameViewModel: MillGameViewModel?
    @Published var coins: Int = 0 {
        didSet {
            checkAchievementsAsync()
        }
    }
    @Published var currentLevel: Int = 1
    @Published var currentBackground: ImageResource = .bgimg1
    @Published var currentChipSkin: (player1: ImageResource, player2: ImageResource) = (.chip1, .chip11)
    @Published var totalGamesPlayed: Int = 0
    @Published var achievementViewModel: AchievementViewModel?
    
    // Daily reward properties
    @Published var remainingTime: String = ""
    @Published var isRewardAvailable: Bool = false
    
    private var rewardTimer: AnyCancellable?
    private let dailyRewardAmount: Int = 10
    
    // Данные для сохранения прогресса
    private var levelsCompleted: Int = 0
    private var millsFormed: Int = 0
    private var maxCompletedLevel: Int = 0
    private var lastDailyRewardClaimDate: Date?
    
    // UserDefaults ключи
    private let coinsKey = "goldenMoon.coins"
    private let currentLevelKey = "goldenMoon.currentLevel"
    private let levelsCompletedKey = "goldenMoon.levelsCompleted"
    private let millsFormedKey = "goldenMoon.millsFormed"
    private let maxCompletedLevelKey = "goldenMoon.maxCompletedLevel"
    private let lastDailyRewardKey = "goldenMoon.lastDailyReward"
    private let totalGamesPlayedKey = "goldenMoon.totalGamesPlayed"
    private let currentBackgroundKey = "goldenMoon.currentBackground"
    private let currentChipSkinKey = "goldenMoon.currentChipSkin"
    private let tutorialCompletedKey = "goldenMoon.tutorialCompleted"
    
    init() {
        // Загрузка сохраненных данных
        self.coins = UserDefaults.standard.integer(forKey: coinsKey)
        self.currentLevel = UserDefaults.standard.integer(forKey: currentLevelKey)
        self.levelsCompleted = UserDefaults.standard.integer(forKey: levelsCompletedKey)
        self.millsFormed = UserDefaults.standard.integer(forKey: millsFormedKey)
        self.maxCompletedLevel = UserDefaults.standard.integer(forKey: maxCompletedLevelKey)
        self.totalGamesPlayed = UserDefaults.standard.integer(forKey: totalGamesPlayedKey)
        
        // Загрузка сохраненного фона
        if let backgroundString = UserDefaults.standard.string(forKey: currentBackgroundKey),
           let background = imageResourceFromString(backgroundString) {
            self.currentBackground = background
        }
        
        // Загрузка сохраненных скинов фишек
        if let data = UserDefaults.standard.data(forKey: currentChipSkinKey),
           let skinPair = try? JSONDecoder().decode([String].self, from: data),
           skinPair.count == 2,
           let chip1 = imageResourceFromString(skinPair[0]),
           let chip2 = imageResourceFromString(skinPair[1]) {
            self.currentChipSkin = (chip1, chip2)
        }
        
        // Загрузка даты последнего получения награды
        if let dateData = UserDefaults.standard.data(forKey: lastDailyRewardKey),
           let date = try? JSONDecoder().decode(Date.self, from: dateData) {
            self.lastDailyRewardClaimDate = date
        }
        
        // Установка минимальных значений
        if self.currentLevel < 1 {
            self.currentLevel = 1
        }
        
        // Инициализация ежедневных наград
        updateDailyRewardState()
        startDailyRewardTimer()
    }
    
    deinit {
        rewardTimer?.cancel()
    }
    
    // MARK: - Helper methods
    
    // Вспомогательная функция для конвертации String в ImageResource
    private func imageResourceFromString(_ string: String) -> ImageResource? {
        switch string {
        case "bgimg0": return .bgimg0
        case "bgimg1": return .bgimg1
        case "bgimg2": return .bgimg2
        case "bgimg3": return .bgimg3
        case "chip1": return .chip1
        case "chip11": return .chip11
        case "chip2": return .chip2
        case "chip22": return .chip22
        case "chip3": return .chip3
        case "chip33": return .chip33
        case "chip4": return .chip4
        case "chip44": return .chip44
        default: return nil
        }
    }
    
    // Вспомогательная функция для конвертации ImageResource в String
    private func stringFromImageResource(_ resource: ImageResource) -> String {
        switch resource {
        case .bgimg0: return "bgimg0"
        case .bgimg1: return "bgimg1"
        case .bgimg2: return "bgimg2"
        case .bgimg3: return "bgimg3"
        case .chip1: return "chip1"
        case .chip11: return "chip11"
        case .chip2: return "chip2"
        case .chip22: return "chip22"
        case .chip3: return "chip3"
        case .chip33: return "chip33"
        case .chip4: return "chip4"
        case .chip44: return "chip44"
        default: return "unknown"
        }
    }
    
    // MARK: - Achievement Check
    
    private func checkAchievementsAsync() {
        Task { @MainActor in
            if let achievementViewModel = achievementViewModel {
                achievementViewModel.checkAchievements()
            }
        }
    }
    
    // MARK: - Daily Reward Methods
    
    func claimDailyReward() -> Bool {
        guard isRewardAvailable else { return false }
        
        // Добавляем монеты
        coins += dailyRewardAmount
        
        // Сохраняем текущую дату
        lastDailyRewardClaimDate = Date()
        
        // Сохраняем в UserDefaults
        saveGameState()
        
        // Обновляем состояние
        updateDailyRewardState()
        
        return true
    }
    
    func updateDailyRewardState() {
        let lastClaimDate = lastDailyRewardClaimDate
        
        if let lastDate = lastClaimDate {
            let isToday = Calendar.current.isDateInToday(lastDate)
            isRewardAvailable = !isToday
            
            if isToday {
                let remainingSeconds = calculateRemainingTime(from: lastDate)
                remainingTime = formatRemainingTime(remainingSeconds)
            } else {
                remainingTime = "Available"
            }
        } else {
            isRewardAvailable = true
            remainingTime = "Available"
        }
    }
    
    private func startDailyRewardTimer() {
        rewardTimer?.cancel()
        rewardTimer = Timer.publish(every: 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDailyRewardState()
            }
    }
    
    private func calculateRemainingTime(from date: Date) -> TimeInterval {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) else {
            return 0
        }
        return max(0, tomorrow.timeIntervalSince(Date()))
    }
    
    private func formatRemainingTime(_ timeInterval: TimeInterval) -> String {
        if timeInterval <= 0 {
            return "Available"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    // MARK: - Navigation
    
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }
    
    func startGame(mode: MillGameMode = .twoPlayers) {
        millGameViewModel = MillGameViewModel(gameMode: mode)
        millGameViewModel?.appViewModel = self
        
        // Проверяем, завершен ли туториал
        let tutorialCompleted = UserDefaults.standard.bool(forKey: tutorialCompletedKey)
        
        // Показываем туториал только если он еще не был завершен
        if !tutorialCompleted {
            millGameViewModel?.showTutorial = true
        } else {
            millGameViewModel?.showTutorial = false
        }
        
        navigateTo(.game)
    }
    
    func completeTutorial() {
        // Сохраняем состояние туториала как завершенное
        UserDefaults.standard.set(true, forKey: tutorialCompletedKey)
        UserDefaults.standard.synchronize()
        
        // Обновляем флаг в viewModel
        millGameViewModel?.showTutorial = false
    }
    
    func goToMenu() {
        millGameViewModel = nil
        navigateTo(.menu)
    }
    
    // MARK: - Game State
    
    func showVictory() {
        // Базовая награда за победу
        let reward = 10
        coins += reward
        levelsCompleted += 1
        totalGamesPlayed += 1
        
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
        
        // Проверяем достижения
        checkAchievementsAsync()
    }
    
    func showDefeat() {
        // Можно добавить небольшую награду за попытку
        let consolationReward = 1
        coins += consolationReward
        totalGamesPlayed += 1
        saveGameState()
        
        // Проверяем достижения
        checkAchievementsAsync()
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сбрасываем текущую игру и создаем новую
            let gameMode = self.millGameViewModel?.game.gameMode ?? .twoPlayers
            self.millGameViewModel = MillGameViewModel(gameMode: gameMode)
            self.millGameViewModel?.appViewModel = self
            
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
    
    // Метод для обновления фона и скинов от ShopViewModel
    func updateAppearance(background: ImageResource? = nil, chipSkin: (player1: ImageResource, player2: ImageResource)? = nil) {
        if let bg = background {
            self.currentBackground = bg
        }
        if let skin = chipSkin {
            self.currentChipSkin = skin
        }
        saveGameState()
    }
    
    func saveGameState() {
        UserDefaults.standard.set(coins, forKey: coinsKey)
        UserDefaults.standard.set(currentLevel, forKey: currentLevelKey)
        UserDefaults.standard.set(levelsCompleted, forKey: levelsCompletedKey)
        UserDefaults.standard.set(millsFormed, forKey: millsFormedKey)
        UserDefaults.standard.set(maxCompletedLevel, forKey: maxCompletedLevelKey)
        UserDefaults.standard.set(totalGamesPlayed, forKey: totalGamesPlayedKey)
        
        // Сохранение текущего фона
        UserDefaults.standard.set(stringFromImageResource(currentBackground), forKey: currentBackgroundKey)
        
        // Сохранение текущих скинов фишек
        let currentSkinStrings = [stringFromImageResource(currentChipSkin.0), stringFromImageResource(currentChipSkin.1)]
        if let data = try? JSONEncoder().encode(currentSkinStrings) {
            UserDefaults.standard.set(data, forKey: currentChipSkinKey)
        }
        
        // Сохраняем дату последнего получения награды
        if let date = lastDailyRewardClaimDate,
           let encoded = try? JSONEncoder().encode(date) {
            UserDefaults.standard.set(encoded, forKey: lastDailyRewardKey)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func resetAllProgress() {
        coins = 0
        currentLevel = 1
        levelsCompleted = 0
        millsFormed = 0
        maxCompletedLevel = 0
        totalGamesPlayed = 0
        lastDailyRewardClaimDate = nil
        
        UserDefaults.standard.removeObject(forKey: coinsKey)
        UserDefaults.standard.removeObject(forKey: currentLevelKey)
        UserDefaults.standard.removeObject(forKey: levelsCompletedKey)
        UserDefaults.standard.removeObject(forKey: millsFormedKey)
        UserDefaults.standard.removeObject(forKey: maxCompletedLevelKey)
        UserDefaults.standard.removeObject(forKey: totalGamesPlayedKey)
        UserDefaults.standard.removeObject(forKey: lastDailyRewardKey)
        UserDefaults.standard.removeObject(forKey: currentBackgroundKey)
        UserDefaults.standard.removeObject(forKey: currentChipSkinKey)
        UserDefaults.standard.removeObject(forKey: tutorialCompletedKey)
        UserDefaults.standard.synchronize()
    }
}

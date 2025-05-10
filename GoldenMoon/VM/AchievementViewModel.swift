//
//  AchievementViewModel.swift
//  GoldenMoon
//
//  Created by Alex on 10.05.2025.
//

import SwiftUI

@MainActor
class AchievementViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var unlockedAchievements: Set<String> = []
    
    weak var appViewModel: AppViewModel?
    
    private let unlockedAchievementsKey = "goldenMoon.unlockedAchievements"
    
    init() {
        loadUnlockedAchievements()
    }
    
    private func loadUnlockedAchievements() {
        if let data = UserDefaults.standard.data(forKey: unlockedAchievementsKey),
           let achievements = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.unlockedAchievements = achievements
        }
    }
    
    private func saveUnlockedAchievements() {
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(data, forKey: unlockedAchievementsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func checkAchievements(shopViewModel: ShopViewModel? = nil) {
        guard let appViewModel = appViewModel else { return }
        
        // Проверка на все фоны
        if let shopViewModel = shopViewModel {
            let allBackgroundsPurchased = shopViewModel.availableBackgrounds
                .filter { $0.price > 0 }
                .allSatisfy { shopViewModel.purchasedBackgrounds.contains($0.image) }
            
            if allBackgroundsPurchased {
                unlockAchievement("all_backgrounds")
            }
            
            // Проверка на все скины фишек
            let allChipsPurchased = shopViewModel.availableChipSkins
                .filter { $0.price > 0 }
                .allSatisfy { skin in
                    shopViewModel.purchasedChipSkins.contains {
                        $0.player1 == skin.player1 && $0.player2 == skin.player2
                    }
                }
            
            if allChipsPurchased {
                unlockAchievement("all_chips")
            }
        }
        
        // Проверка на 10 матчей
        if appViewModel.totalGamesPlayed >= 10 {
            unlockAchievement("ten_matches")
        }
        
        // Проверка на 10000 монет
        if appViewModel.coins >= 10000 {
            unlockAchievement("rich_player")
        }
    }
    
    func unlockAchievement(_ id: String) {
        if !unlockedAchievements.contains(id) {
            unlockedAchievements.insert(id)
            saveUnlockedAchievements()
        }
    }
    
    func isAchievementUnlocked(_ id: String) -> Bool {
        return unlockedAchievements.contains(id)
    }
    
    func nextAchievement() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex = (currentIndex + 1) % Achievement.all.count
        }
    }
    
    func previousAchievement() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex = (currentIndex - 1 + Achievement.all.count) % Achievement.all.count
        }
    }
}

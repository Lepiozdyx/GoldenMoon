//
//  ContentView.swift
//  GoldenMoon

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var achievementViewModel = AchievementViewModel()
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                
            case .game:
                if let gameViewModel = appViewModel.millGameViewModel {
                    GameView(viewModel: gameViewModel)
                        .environmentObject(appViewModel)
                }
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                
            case .achievements:
                AchievementsView()
                    .environmentObject(appViewModel)
                
            case .reward:
                RewardView()
                    .environmentObject(appViewModel)
            }
        }
        .onAppear {
            appViewModel.achievementViewModel = achievementViewModel
            achievementViewModel.appViewModel = appViewModel
        }
    }
}

#Preview {
    ContentView()
}

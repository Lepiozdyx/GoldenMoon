//
//  ContentView.swift
//  GoldenMoon

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var achievementViewModel = AchievementViewModel()
    
    private var orientation = OrientationManager.shared
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .mode:
                ModeView()
                    .environmentObject(appViewModel)
                
            case .game:
                if let gameViewModel = appViewModel.millGameViewModel {
                    GameView(viewModel: gameViewModel)
                        .environmentObject(appViewModel)
                        .onAppear {
                            orientation.lockLandscape()
                        }
                }
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .achievements:
                AchievementsView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .reward:
                RewardView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .miniGames:
                MiniGamesView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .guessNumber:
                GuessNumberView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .memoryCards:
                MemoryGameView()
                    .environmentObject(appViewModel)
                
            case .sequence:
                SequenceGameView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
            }
        }
        .onAppear {
            appViewModel.achievementViewModel = achievementViewModel
            achievementViewModel.appViewModel = appViewModel
        }
        .onAppear {
            if settings.isMusicOn {
                settings.playMusic()
            }
        }
        .onChange(of: scenePhase) { state in
            switch state {
            case .active:
                settings.playMusic()
            case .background, .inactive:
                settings.stopMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}

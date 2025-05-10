//
//  AchievementsView.swift
//  GoldenMoon
//
//  Created by Alex on 10.05.2025.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var achievementViewModel = AchievementViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView(name: appViewModel.currentBackground)
            
            VStack {
                HStack(alignment: .top) {
                    SquareButtonView(image: .arrow) {
                        settings.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    Image(.labelGroup)
                        .resizable()
                        .frame(width: 255, height: 75)
                        .overlay {
                            Text("Achievements")
                                .customFont(26)
                        }
                    
                    Spacer()
                    
                    ScoreboardView(amount: appViewModel.coins)
                }
                
                Spacer()
                
                VStack(spacing: 30) {
                    HStack {
                        Button {
                            settings.play()
                            achievementViewModel.previousAchievement()
                        } label: {
                            Image(.buttonGroupArrow)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                        }
                        
                        HStack {
                            // Карусель достижений
                            if achievementViewModel.currentIndex < Achievement.all.count {
                                let achievement = Achievement.all[achievementViewModel.currentIndex]
                                let isUnlocked = achievementViewModel.isAchievementUnlocked(achievement.id)
                                
                                VStack(spacing: 2) {
                                    Image(achievement.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150)
                                        .opacity(isUnlocked ? 1.0 : 0.5)
                                    
                                    Text(achievement.title)
                                        .customFont(12)
                                        .opacity(isUnlocked ? 1.0 : 0.7)
                                    
                                    Text(achievement.description)
                                        .customFont(8)
                                        .multilineTextAlignment(.center)
                                        .opacity(isUnlocked ? 1.0 : 0.7)
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                        .frame(width: 250)
                        .animation(.easeInOut(duration: 0.3), value: achievementViewModel.currentIndex)

                        Button {
                            settings.play()
                            achievementViewModel.nextAchievement()
                        } label: {
                            Image(.buttonGroupArrow)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .scaleEffect(x: -1)
                        }
                    }
                    
                    // Индикаторы страниц
                    HStack(spacing: 8) {
                        ForEach(0..<Achievement.all.count, id: \.self) { index in
                            Circle()
                                .fill(index == achievementViewModel.currentIndex ? Color.yellow : Color.gray)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(.horizontal, 80)
                .padding(.vertical, 40)
                .background(
                    Image(.frame)
                        .resizable()
                )
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            achievementViewModel.appViewModel = appViewModel
            appViewModel.achievementViewModel = achievementViewModel
            achievementViewModel.checkAchievements()
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AppViewModel())
}

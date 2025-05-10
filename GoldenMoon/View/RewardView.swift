//
//  RewardView.swift
//  GoldenMoon
//
//  Created by Alex on 10.05.2025.
//

import SwiftUI

struct RewardView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            BackgroundView(name: appViewModel.currentBackground)
            
            VStack {
                HStack {
                    SquareButtonView(image: .arrow) {
                        settings.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    ScoreboardView(amount: appViewModel.coins)
                }
                Spacer()
            }
            .padding()
            
            VStack(spacing: 10) {
                Text("Daily entry reward")
                    .customFont(22)
                
                Image(.calendar)
                    .resizable()
                    .frame(width: 120, height: 120)
                
                MainButtonView(
                    label: appViewModel.isRewardAvailable ? "+10" : appViewModel.remainingTime,
                    labelSize: 16,
                    width: 150,
                    height: 50
                ) {
                    if appViewModel.isRewardAvailable {
                        settings.play()
                        _ = appViewModel.claimDailyReward()
                    }
                }
                .overlay {
                    if appViewModel.isRewardAvailable {
                        Image(.coin)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .offset(x: 45, y: -2)
                    }
                }
                .disabled(!appViewModel.isRewardAvailable)
                .opacity(appViewModel.isRewardAvailable ? 1.0 : 0.6)
            }
            .frame(width: 250)
            .padding(.horizontal, 80)
            .padding(.vertical, 40)
            .background(
                Image(.frame)
                    .resizable()
            )
        }
        .onAppear {
            appViewModel.updateDailyRewardState()
        }
    }
}

#Preview {
    RewardView()
        .environmentObject(AppViewModel())
}

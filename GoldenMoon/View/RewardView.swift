//
//  RewardView.swift
//  GoldenMoon

import SwiftUI

struct RewardView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var settings = SettingsViewModel.shared
    
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
                    
                    ScoreboardView(amount: appViewModel.coins)
                }
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Daily entry reward")
                        .customFont(18)
                    
                    Image(.calendar)
                        .resizable()
                        .frame(width: 100, height: 100)
                    
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
                .padding(.vertical, 30)
                .background(
                    Image(.frame)
                        .resizable()
                )
                
                Spacer()
            }
            .padding()
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

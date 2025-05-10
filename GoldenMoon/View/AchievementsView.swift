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
    
    var body: some View {
        ZStack {
            BackgroundView(name: .bgimg1)
            
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
                            // previous achievement
                        } label: {
                            Image(.buttonGroupArrow)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                        }
                        
                        HStack {
                            // achievements carousel [.achi1, .achi2, .achi3, .achi4]
                            Image(.achi1)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                        }
                        .frame(width: 250)

                        Button {
                            // next achievement
                        } label: {
                            Image(.buttonGroupArrow)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .scaleEffect(x: -1)
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
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AppViewModel())
}

//
//  MiniGamesView.swift
//  GoldenMoon

import SwiftUI

struct MiniGamesView: View {
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
                    
                    Image(.labelGroup)
                        .resizable()
                        .frame(width: 255, height: 75)
                        .overlay {
                            Text("Mini-Games")
                                .customFont(26)
                        }
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 10) {
                    ForEach(MiniGameType.allCases) { gameType in
                        MiniGameItemView(gameType: gameType) {
                            settings.play()
                            appViewModel.startMiniGame(gameType: gameType)
                        }
                    }
                }
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
    }
}

struct MiniGameItemView: View {
    let gameType: MiniGameType
    let action: () -> Void
    
    var body: some View {
        MainButtonView(
            label: gameType.title,
            labelSize: 14,
            width: 180,
            height: 55,
            action: action
        )
    }
}

#Preview {
    MiniGamesView()
        .environmentObject(AppViewModel())
}

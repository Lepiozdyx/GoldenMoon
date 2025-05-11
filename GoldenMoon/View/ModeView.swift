//
//  ModeView.swift
//  GoldenMoon
//
//  Created by Alex on 08.05.2025.
//

import SwiftUI

struct ModeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            BackgroundView(name: appViewModel.currentBackground)
            
            VStack {
                Image(.labelGroup)
                    .resizable()
                    .frame(width: 180, height: 75)
                    .overlay {
                        Text("Mode")
                            .customFont(28)
                    }
                
                Spacer()
            }
            .padding()
            
            VStack {
                HStack {
                    SquareButtonView(image: .arrow) {
                        settings.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
            
            HStack(spacing: 60) {
                MainButtonView(label: "Solo", labelSize: 20) {
                    settings.play()
                    appViewModel.startGame(mode: .vsAI)
                }
                
                MainButtonView(label: "Two Players", labelSize: 20) {
                    settings.play()
                    appViewModel.startGame(mode: .twoPlayers)
                }
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    ModeView()
        .environmentObject(AppViewModel())
}

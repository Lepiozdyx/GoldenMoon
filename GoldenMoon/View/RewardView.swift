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
            BackgroundView(name: .bgimg1)
            
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
            
            VStack(spacing: 10) {
                Text("Daily entry reward")
                    .customFont(22)
                
                Image(.calendar)
                    .resizable()
                    .frame(width: 120, height: 120)
                
                MainButtonView(label: "+10", labelSize: 16, width: 150, height: 50) {
                    settings.play()
                    // get daily reward
                }
                .overlay {
                    Image(.coin)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .offset(x: 45, y: -2)
                }
            }
            .frame(width: 250)
            .padding(.horizontal, 80)
            .padding(.vertical, 50)
            .background(
                Image(.frame)
                    .resizable()
            )
        }
    }
}

#Preview {
    RewardView()
}

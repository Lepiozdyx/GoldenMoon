//
//  MenuView.swift
//  GoldenMoon

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            BackgroundView(name: appViewModel.currentBackground)
            
            EmblemView()
            
            SidebarView()
            
            VStack(spacing: 15) {
                Spacer()
                
                MainButtonView(label: "Play", labelSize: 20) {
                    settings.play()
                    appViewModel.navigateTo(.mode)
                }
                
                MainButtonView(label: "Achieve", labelSize: 20) {
                    settings.play()
                    appViewModel.navigateTo(.achievements)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}

struct EmblemView: View {
    var body: some View {
        VStack {
            Image(.emblem)
                .resizable()
                .scaledToFit()
                .frame(height: 110)
            
            Spacer()
        }
        .padding()
    }
}

struct SidebarView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                SquareButtonView(image: .gear) {
                    settings.play()
                    appViewModel.navigateTo(.settings)
                }
                
                Spacer()
                
                ScoreboardView(amount: appViewModel.coins)
            }
            
            Spacer()
            
            HStack {
                SquareButtonView(image: .joystick) {
                    settings.play()
                    appViewModel.navigateTo(.miniGames)
                }
                
                SquareButtonView(image: .i) {
                    settings.play()
                    appViewModel.navigateTo(.reward)
                }
                
                Spacer()
                
                SquareButtonView(image: .shop) {
                    settings.play()
                    appViewModel.navigateTo(.shop)
                }
            }
        }
        .padding()
    }
}

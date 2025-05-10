//
//  SettingsView.swift
//  GoldenMoon
//
//  Created by Alex on 10.05.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            BackgroundView(name: appViewModel.currentBackground)
            
            VStack {
                Image(.labelGroup)
                    .resizable()
                    .frame(width: 180, height: 75)
                    .overlay {
                        Text("Settings")
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
            
            VStack(spacing: 20) {
                SettingsItemView(
                    title: "Sound",
                    isOn: settings.isSoundOn,
                    action: {
                        settings.toggleSound()
                    }
                )
                
                SettingsItemView(
                    title: "Music",
                    isOn: settings.isMusicOn,
                    isDisabled: !settings.isSoundOn,
                    action: {
                        settings.toggleMusic()
                    }
                )
            }
            .frame(width: 200)
            .padding(.horizontal, 80)
            .padding(.vertical, 50)
            .background(
                Image(.frame)
                    .resizable()
            )
        }
    }
}

struct SettingsItemView: View {
    let title: String
    let isOn: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .customFont(16)
            
            Spacer()
            
            SwitcherView(isOn: isOn, isDisabled: isDisabled, action: action)
        }
    }
}

struct SwitcherView: View {
    let isOn: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Image(.redsquare)
                    .resizable()
                    .frame(width: 40, height: 40)
                
                if isOn {
                    Image(.check)
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            }
        }
        .disabled(isDisabled)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}

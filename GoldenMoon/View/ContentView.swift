//
//  ContentView.swift
//  GoldenMoon

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                
            case .game:
                if let gameViewModel = appViewModel.millGameViewModel {
                    GameView(viewModel: gameViewModel)
                        .environmentObject(appViewModel)
                }
                
            case .settings:
                Text("Settings view (Coming soon)")
                    .font(.largeTitle)
                    .onTapGesture {
                        appViewModel.navigateTo(.menu)
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}

//
//  VictoryOverlayView.swift
//  GoldenMoon

import SwiftUI

struct VictoryOverlayView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showCoins = false
    @State private var navigating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(.win)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 85)
                
                if showCoins {
                    ScoreboardView(amount: 100)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 1.0), value: showCoins)
                }
                
                HStack(spacing: 20) {
                    MainButtonView(label: "Menu", labelSize: 22, width: 150, height: 65) {
                        guard !navigating else { return }
                        navigating = true
                        appViewModel.goToMenu()
                    }
                    .disabled(navigating)
                    
                    MainButtonView(label: "Next lvl", labelSize: 22, width: 150, height: 65) {
                        guard !navigating else { return }
                        navigating = true
                        appViewModel.goToNextLevel()
                    }
                    .disabled(navigating)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.showCoins = true
                }
            }
        }
    }
}

#Preview {
    VictoryOverlayView()
}

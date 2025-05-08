//
//  PauseOverlayView.swift
//  GoldenMoon

import SwiftUI

struct PauseOverlayView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                Text("PAUSED")
                    .customFont(36)
                
                MainButtonView(label: "Resume", labelSize: 22, width: 150, height: 65) {
                    appViewModel.millGameViewModel?.resumeGame()
                }
                
                MainButtonView(label: "Restart", labelSize: 22, width: 150, height: 65) {
                    appViewModel.millGameViewModel?.resetGame()
                    appViewModel.millGameViewModel?.resumeGame()
                }
                
                MainButtonView(label: "Menu", labelSize: 22, width: 150, height: 65) {
                    appViewModel.goToMenu()
                }
            }
        }
    }
}

#Preview {
    PauseOverlayView()
}

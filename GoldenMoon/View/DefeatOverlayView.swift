//
//  DefeatOverlayView.swift
//  GoldenMoon

import SwiftUI

struct DefeatOverlayView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("GAME OVER")
                    .customFont(36)
                    .colorMultiply(.red)
                
                HStack(spacing: 20) {
                    MainButtonView(label: "Menu", labelSize: 22, width: 150, height: 65) {
                        appViewModel.goToMenu()
                    }
                    
                    MainButtonView(label: "Restart", labelSize: 22, width: 150, height: 65) {
                        appViewModel.millGameViewModel?.resetGame()
                        appViewModel.millGameViewModel?.resumeGame()
                    }
                }
            }
        }
    }
}

#Preview {
    DefeatOverlayView()
}

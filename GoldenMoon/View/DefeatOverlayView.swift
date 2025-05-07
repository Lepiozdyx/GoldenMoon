//
//  DefeatOverlayView.swift
//  GoldenMoon

import SwiftUI

struct DefeatOverlayView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("GAME OVER")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Button(action: {
                    appViewModel.millGameViewModel?.resetGame()
                    appViewModel.millGameViewModel?.resumeGame()
                }) {
                    Text("TRY AGAIN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(Color.green)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        )
                }
                
                Button(action: {
                    appViewModel.goToMenu()
                }) {
                    Text("MENU")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        )
                }
            }
        }
    }
}

#Preview {
    DefeatOverlayView()
}

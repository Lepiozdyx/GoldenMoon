//
//  MenuView.swift
//  GoldenMoon

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Button(action: {
                    appViewModel.startGame(mode: .twoPlayers)
                }) {
                    Text("Two Players")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.blue)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        )
                }
                
                Button(action: {
                    appViewModel.startGame(mode: .vsAI)
                }) {
                    Text("Play vs CPU")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
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
                    appViewModel.startGame(mode: .tutorial)
                }) {
                    Text("Tutorial")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.orange)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        )
                }
                
                // Кнопка настроек (в будущем)
                Button(action: {
                    appViewModel.navigateTo(.settings)
                }) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 150)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.gray)
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
    MenuView()
        .environmentObject(AppViewModel())
}

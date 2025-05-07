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
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("YOU WIN!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                if showCoins {
                    HStack {
                        Text("+10")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        
                        Image(systemName: "bitcoinsign.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.yellow)
                    }
                    .scaleEffect(showCoins ? 1.5 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 1.0), value: showCoins)
                }
                
                Button(action: {
                    guard !navigating else { return }
                    navigating = true
                    appViewModel.goToNextLevel()
                }) {
                    Text("NEXT LEVEL")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(navigating ? Color.gray : Color.green)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        )
                }
                .disabled(navigating)
                
                Button(action: {
                    guard !navigating else { return }
                    navigating = true
                    
                    appViewModel.goToMenu()
                }) {
                    Text("MENU")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(navigating ? Color.gray : Color.blue)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        )
                }
                .disabled(navigating)
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

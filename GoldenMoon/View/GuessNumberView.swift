//
//  GuessNumberView.swift
//  GoldenMoon
//
//  Created by Alex on 11.05.2025.
//

import SwiftUI

struct GuessNumberView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GuessNumberViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    @State private var hasAwardedCoins = false
    @State private var sliderValue: Double = 500
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView(name: appViewModel.currentBackground)
                
                VStack {
                    HStack(alignment: .top) {
                        SquareButtonView(image: .arrow) {
                            settings.play()
                            appViewModel.navigateTo(.miniGames)
                        }
                        
                        Spacer()
                        
                        Image(.labelGroup)
                            .resizable()
                            .frame(width: min(geometry.size.width * 0.3, 255), height: min(geometry.size.width * 0.09, 75))
                            .overlay {
                                Text("Guess the Number")
                                    .customFont(min(geometry.size.width * 0.025, 20))
                            }
                        
                        Spacer()
                        
                        // Current guess display
                        ZStack {
                            Image(.underlayGroup)
                                .resizable()
                                .frame(width: min(geometry.size.width * 0.2, 150), height: min(geometry.size.width * 0.09, 75))
                            
                            Text("\(Int(sliderValue))")
                                .customFont(min(geometry.size.width * 0.028, 22))
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        // Feedback message
                        Text(viewModel.feedbackMessage)
                            .customFont(min(geometry.size.width * 0.02, 16))
                        
                        HStack(spacing: 10) {
                            // Slider
                            HStack(spacing: 2) {
                                Text("0")
                                    .customFont(min(geometry.size.width * 0.012, 10))
                                
                                Slider(value: $sliderValue, in: 0...999, step: 1)
                                    .accentColor(.yellow)
                                    .padding(.horizontal)
                                
                                Text("999")
                                    .customFont(min(geometry.size.width * 0.012, 10))
                            }
                            .frame(width: min(geometry.size.width * 0.25, 200))
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.ultraThinMaterial)
                            )
                            
                            Spacer()
                            
                            Button {
                                sliderValue = max(0, sliderValue - 1)
                                settings.play()
                            } label: {
                                Image(.buttonGroup3)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: min(geometry.size.width * 0.07, 55))
                                    .overlay {
                                        Image(systemName: "minus")
                                            .resizable()
                                            .frame(width: min(geometry.size.width * 0.025, 20), height: min(geometry.size.width * 0.004, 3))
                                            .foregroundStyle(.white)
                                            .offset(y: -2)
                                    }
                            }
                            
                            Button {
                                sliderValue = min(999, sliderValue + 1)
                                settings.play()
                            } label: {
                                Image(.buttonGroup3)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: min(geometry.size.width * 0.07, 55))
                                    .overlay {
                                        Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: min(geometry.size.width * 0.025, 20), height: min(geometry.size.width * 0.025, 20))
                                            .foregroundStyle(.white)
                                            .offset(y: -2)
                                    }
                            }
                        }
                        
                        // Action buttons
                        if case .playing = viewModel.gameState {
                            MainButtonView(
                                label: "Guess",
                                labelSize: min(geometry.size.width * 0.022, 18),
                                width: min(geometry.size.width * 0.18, 140),
                                height: min(geometry.size.width * 0.06, 50)
                            ) {
                                settings.play()
                                viewModel.makeGuess(Int(sliderValue))
                            }
                        }
                        
                        if case .guessed(let correct, _) = viewModel.gameState, !correct {
                            MainButtonView(
                                label: "Continue",
                                labelSize: min(geometry.size.width * 0.022, 18),
                                width: min(geometry.size.width * 0.18, 140),
                                height: min(geometry.size.width * 0.06, 50)
                            ) {
                                settings.play()
                                viewModel.continueGame()
                            }
                        }
                        
                        if case .guessed(let correct, _) = viewModel.gameState, correct {
                            VStack(spacing: 20) {
                                Text("Congratulations!")
                                    .customFont(min(geometry.size.width * 0.022, 18))
                                
                                HStack(spacing: 20) {
                                    MainButtonView(
                                        label: "Play Again",
                                        labelSize: min(geometry.size.width * 0.022, 18),
                                        width: min(geometry.size.width * 0.18, 140),
                                        height: min(geometry.size.width * 0.06, 50)
                                    ) {
                                        settings.play()
                                        hasAwardedCoins = false
                                        viewModel.startNewGame()
                                        sliderValue = 500
                                    }
                                    
                                    MainButtonView(
                                        label: "Menu",
                                        labelSize: min(geometry.size.width * 0.022, 18),
                                        width: min(geometry.size.width * 0.18, 140),
                                        height: min(geometry.size.width * 0.06, 50)
                                    ) {
                                        settings.play()
                                        appViewModel.navigateTo(.miniGames)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: min(geometry.size.width * 0.6, 450))
                    .padding(.horizontal, min(geometry.size.width * 0.05, 40))
                    .padding(.vertical, min(geometry.size.width * 0.04, 30))
                    .background(
                        Image(.frame)
                            .resizable()
                    )
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.startNewGame()
            sliderValue = 500
            hasAwardedCoins = false
        }
        .onChange(of: viewModel.gameState) { newState in
            if case .guessed(let correct, _) = newState, correct && !hasAwardedCoins {
                appViewModel.addCoins(MiniGameType.guessNumber.reward)
                hasAwardedCoins = true
            }
        }
    }
}

#Preview {
    GuessNumberView()
        .environmentObject(AppViewModel())
}

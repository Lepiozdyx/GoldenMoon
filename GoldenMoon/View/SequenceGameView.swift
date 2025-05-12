//
//  SequenceGameView.swift
//  GoldenMoon
//
//  Created by Alex on 11.05.2025.
//

import SwiftUI

struct SequenceGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = SequenceGameViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView(name: appViewModel.currentBackground)
                
                VStack {
                    HStack {
                        SquareButtonView(image: .arrow) {
                            settings.play()
                            appViewModel.navigateTo(.miniGames)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Image(.underlayGroup)
                                .resizable()
                                .frame(width: 200, height: 40)
                            
                            Text("Combination: \(viewModel.currentSequenceLength)")
                                .customFont(16)
                        }
                    }
                    
                    Text("Repeat the sequence")
                        .customFont(28)
                        .padding(.vertical)
                    
                    Spacer()
                    
                    VStack(spacing: 40) {
                        // Display area
                        Image(.paper)
                            .resizable()
                            .frame(width: 150, height: 150)
                            .overlay {
                                if let currentImage = viewModel.currentShowingImage {
                                    Image(currentImage.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                        .transition(.scale.combined(with: .opacity))
                                        .id("currentImage-\(currentImage.id)")
                                } else if viewModel.gameState == .playing {
                                    Text("?")
                                        .customFont(60)
                                }
                            }
                            .padding(.top)
                        
                        // Button grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(SequenceGameConstants.availableImages, id: \.self) { imageName in
                                SequenceImageButton(
                                    imageName: imageName,
                                    onTap: {
                                        settings.play()
                                        viewModel.selectImage(SequenceImage(imageName: imageName))
                                    },
                                    disabled: viewModel.gameState != .playing
                                )
                            }
                        }
                        .frame(maxWidth: 350)
                    }
                    .padding()
                    .background(
                        Image(.frame)
                            .resizable()
                    )
                    
                    Spacer()
                }
                .padding()
                
                if viewModel.gameState == .gameOver {
                    gameOverOverlay
                }
                
                if viewModel.gameState == .success {
                    successOverlay
                }
            }
        }
    }
    
    private struct SequenceImageButton: View {
        let imageName: String
        let onTap: () -> Void
        let disabled: Bool
        
        var body: some View {
            Button(action: onTap) {
                ZStack {
                    Image(.paper)
                        .resizable()
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                }
                .frame(width: 90, height: 90)
                .opacity(disabled ? 0.6 : 1.0)
            }
            .disabled(disabled)
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Success!")
                    .customFont(40)
                
                Text("Congratulations!")
                    .customFont(16)
                
                if viewModel.currentSequenceLength == SequenceGameConstants.initialSequenceLength {
                    HStack {
                        Text("+\(MiniGameType.sequence.reward)")
                            .customFont(24)
                        
                        Image(.coin)
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
                
                MainButtonView(
                    label: "Continue",
                    labelSize: 20,
                    width: 200,
                    height: 60
                ) {
                    settings.play()
                    viewModel.nextRound()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.9))
                    .shadow(radius: 10)
            )
        }
    }
    
    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Game Over")
                    .customFont(40)
                    .foregroundStyle(.red)
                
                Text("You made a mistake in the sequence.")
                    .customFont(16)
                
                if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                    HStack {
                        Text("+\(MiniGameType.sequence.reward)")
                            .customFont(24)
                        
                        Image(.coin)
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
                
                MainButtonView(
                    label: "Try Again",
                    labelSize: 20,
                    width: 200,
                    height: 60
                ) {
                    settings.play()
                    if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                        appViewModel.addCoins(MiniGameType.sequence.reward)
                    }
                    viewModel.restartAfterGameOver()
                }
                
                MainButtonView(
                    label: "Back to Menu",
                    labelSize: 20,
                    width: 200,
                    height: 60
                ) {
                    settings.play()
                    if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                        appViewModel.addCoins(MiniGameType.sequence.reward)
                    }
                    appViewModel.navigateTo(.miniGames)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.9))
                    .shadow(radius: 10)
            )
        }
    }
}

#Preview {
    SequenceGameView()
        .environmentObject(AppViewModel())
}

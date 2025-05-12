//
//  SequenceGameView.swift
//  GoldenMoon

import SwiftUI

struct SequenceGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = SequenceGameViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView(name: appViewModel.currentBackground)
                
                switch viewModel.gameState {
                case .showing, .playing:
                    gamePlayView(geometry: geometry)
                case .success:
                    gameOverView(success: true)
                case .gameOver:
                    gameOverView(success: false)
                }
            }
            .onAppear {
                viewModel.startNewGame()
            }
        }
    }
    
    private func gamePlayView(geometry: GeometryProxy) -> some View {
        VStack {
            // Header
            HStack(alignment: .top) {
                SquareButtonView(image: .arrow) {
                    settings.play()
                    appViewModel.navigateTo(.miniGames)
                }
                
                Spacer()
                
                Image(.labelGroup)
                    .resizable()
                    .frame(width: 255, height: 75)
                    .overlay {
                        Text("Repeat the sequence")
                            .customFont(16)
                    }
                
                Spacer()
                
                // Sequence counter
                Image(.underlayGroup)
                    .resizable()
                    .frame(width: 200, height: 75)
                    .overlay {
                        Text("Combination: \(viewModel.currentSequenceLength)")
                            .customFont(16)
                            .offset(y: -2)
                    }
            }
            .padding()
            
            Spacer()
            
            // Game area
            HStack(spacing: 10) {
                // Display area
                Image(.paper)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.4, 150))
                    .overlay {
                        if let currentImage = viewModel.currentShowingImage {
                            Image(currentImage.imageName)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .transition(.scale.combined(with: .opacity))
                                .id("currentImage-\(currentImage.id)")
                        } else if viewModel.gameState == .playing {
                            
                        }
                    }
                    .padding(.leading)
                
                // Button grid
                let buttonSize = min(geometry.size.width * 0.2, 90)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(SequenceGameConstants.availableImages, id: \.self) { imageName in
                        SequenceImageButton(
                            imageName: imageName,
                            onTap: {
                                settings.play()
                                viewModel.selectImage(SequenceImage(imageName: imageName))
                            },
                            disabled: viewModel.gameState != .playing,
                            size: buttonSize
                        )
                    }
                }
                .frame(maxWidth: min(geometry.size.width * 0.9, 450))
            }
            .padding(25)
            .background(
                Image(.frame)
                    .resizable()
            )
            
            Spacer()
        }
    }
    
    private func gameOverView(success: Bool) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                if success {
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
                        labelSize: 18,
                        width: 180,
                        height: 55
                    ) {
                        settings.play()
                        viewModel.nextRound()
                    }
                } else {
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
                        labelSize: 18,
                        width: 180,
                        height: 55
                    ) {
                        settings.play()
                        if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                            appViewModel.addCoins(MiniGameType.sequence.reward)
                        }
                        viewModel.restartAfterGameOver()
                    }
                    
                    MainButtonView(
                        label: "Back to Menu",
                        labelSize: 18,
                        width: 180,
                        height: 55
                    ) {
                        settings.play()
                        if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                            appViewModel.addCoins(MiniGameType.sequence.reward)
                        }
                        appViewModel.navigateTo(.miniGames)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(
                Image(.frame)
                    .resizable()
            )
        }
    }
}

struct SequenceImageButton: View {
    let imageName: String
    let onTap: () -> Void
    let disabled: Bool
    let size: CGFloat
    
    var body: some View {
        Button(action: onTap) {
            Image(.buttonGroup1)
                .resizable()
                .overlay {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(width: size, height: size)
                .opacity(disabled ? 0.6 : 1.0)
        }
        .disabled(disabled)
    }
}

#Preview {
    SequenceGameView()
        .environmentObject(AppViewModel())
}

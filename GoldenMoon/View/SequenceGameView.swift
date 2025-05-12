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
                    gameOverView(success: true, geometry: geometry)
                case .gameOver:
                    gameOverView(success: false, geometry: geometry)
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
                    .frame(width: min(geometry.size.width * 0.3, 255), height: min(geometry.size.width * 0.09, 75))
                    .overlay {
                        Text("Repeat the sequence")
                            .customFont(min(geometry.size.width * 0.02, 16))
                    }
                
                Spacer()
                
                // Sequence counter
                Image(.underlayGroup)
                    .resizable()
                    .frame(width: min(geometry.size.width * 0.24, 200), height: min(geometry.size.width * 0.09, 75))
                    .overlay {
                        Text("Combination: \(viewModel.currentSequenceLength)")
                            .customFont(min(geometry.size.width * 0.02, 16))
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
                    .frame(width: min(geometry.size.width * 0.25, 150))
                    .overlay {
                        if let currentImage = viewModel.currentShowingImage {
                            Image(currentImage.imageName)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .transition(.scale.combined(with: .opacity))
                                .id("currentImage-\(currentImage.id)")
                        }
                    }
                    .padding(.leading)
                
                // Button grid
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                
                let buttonSize = min(geometry.size.width * 0.11, 90)
                
                LazyVGrid(columns: columns, spacing: 10) {
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
                .frame(maxWidth: min(geometry.size.width * 0.6, 450))
            }
            .padding(25)
            .background(
                Image(.frame)
                    .resizable()
            )
            
            Spacer()
        }
    }
    
    private func gameOverView(success: Bool, geometry: GeometryProxy) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                if success {
                    Text("Success!")
                        .customFont(min(geometry.size.width * 0.05, 40))
                    
                    Text("Congratulations!")
                        .customFont(min(geometry.size.width * 0.02, 16))
                    
                    if viewModel.currentSequenceLength == SequenceGameConstants.initialSequenceLength {
                        HStack {
                            Text("+\(MiniGameType.sequence.reward)")
                                .customFont(min(geometry.size.width * 0.03, 24))
                            
                            Image(.coin)
                                .resizable()
                                .frame(width: min(geometry.size.width * 0.05, 40), height: min(geometry.size.width * 0.05, 40))
                        }
                    }
                    
                    MainButtonView(
                        label: "Continue",
                        labelSize: min(geometry.size.width * 0.022, 18),
                        width: min(geometry.size.width * 0.22, 180),
                        height: min(geometry.size.width * 0.068, 55)
                    ) {
                        settings.play()
                        viewModel.nextRound()
                    }
                } else {
                    Text("Game Over")
                        .customFont(min(geometry.size.width * 0.05, 40))
                        .foregroundStyle(.red)
                    
                    Text("You made a mistake in the sequence.")
                        .customFont(min(geometry.size.width * 0.02, 16))
                    
                    if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                        HStack {
                            Text("+\(MiniGameType.sequence.reward)")
                                .customFont(min(geometry.size.width * 0.03, 24))
                            
                            Image(.coin)
                                .resizable()
                                .frame(width: min(geometry.size.width * 0.05, 40), height: min(geometry.size.width * 0.05, 40))
                        }
                    }
                    
                    MainButtonView(
                        label: "Try Again",
                        labelSize: min(geometry.size.width * 0.022, 18),
                        width: min(geometry.size.width * 0.22, 180),
                        height: min(geometry.size.width * 0.068, 55)
                    ) {
                        settings.play()
                        if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                            appViewModel.addCoins(MiniGameType.sequence.reward)
                        }
                        viewModel.restartAfterGameOver()
                    }
                    
                    MainButtonView(
                        label: "Back to Menu",
                        labelSize: min(geometry.size.width * 0.022, 18),
                        width: min(geometry.size.width * 0.22, 180),
                        height: min(geometry.size.width * 0.068, 55)
                    ) {
                        settings.play()
                        if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                            appViewModel.addCoins(MiniGameType.sequence.reward)
                        }
                        appViewModel.navigateTo(.miniGames)
                    }
                }
            }
            .padding(.vertical, min(geometry.size.width * 0.025, 20))
            .padding(.horizontal, min(geometry.size.width * 0.05, 40))
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

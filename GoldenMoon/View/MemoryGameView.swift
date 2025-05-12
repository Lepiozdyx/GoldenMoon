//
//  MemoryGameView.swift
//  GoldenMoon

import SwiftUI

struct MemoryGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = MemoryGameViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView(name: appViewModel.currentBackground)
                
                switch viewModel.gameState {
                case .playing:
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
                                    Text("Memory cards")
                                        .customFont(min(geometry.size.width * 0.025, 20))
                                }
                            
                            Spacer()
                            
                            // Timer
                            Image(.underlayGroup)
                                .resizable()
                                .frame(width: min(geometry.size.width * 0.18, 150), height: min(geometry.size.width * 0.09, 75))
                                .overlay {
                                    Text(timeFormatted(viewModel.timeRemaining))
                                        .customFont(min(geometry.size.width * 0.026, 22))
                                        .offset(y: -2)
                                }
                        }
                        .padding()
                        
                        Spacer()
                        
                        // Game board
                        VStack(spacing: 6) {
                            ForEach(0..<3) { row in
                                HStack(spacing: 8) {
                                    ForEach(0..<4) { column in
                                        let position = MemoryCard.Position(row: row, column: column)
                                        if let card = viewModel.cards.first(where: {
                                            $0.position.row == row && $0.position.column == column
                                        }) {
                                            MemoryCardView(
                                                card: card,
                                                onTap: {
                                                    settings.play()
                                                    viewModel.flipCard(at: position)
                                                },
                                                isInteractionDisabled: viewModel.disableCardInteraction,
                                                geometry: geometry
                                            )
                                            .aspectRatio(1, contentMode: .fit)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(35)
                        .background(
                            Image(.frame)
                                .resizable()
                        )
                        
                        Spacer()
                    }
                    
                case .finished(let success):
                    gameOverView(success: success, geometry: geometry)
                }
            }
            .onAppear {
                viewModel.startGameplay()
            }
            .onDisappear {
                viewModel.cleanup()
            }
        }
    }
    
    private func gameOverView(success: Bool, geometry: GeometryProxy) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                if success {
                    Image(.win)
                        .resizable()
                        .scaledToFit()
                        .frame(height: min(geometry.size.width * 0.1, 85))
                } else {
                    Text("Time's Up!")
                        .customFont(min(geometry.size.width * 0.04, 36))
                }
                
                MainButtonView(
                    label: "Back to menu",
                    labelSize: min(geometry.size.width * 0.022, 18),
                    width: min(geometry.size.width * 0.22, 180),
                    height: min(geometry.size.width * 0.068, 55)
                ) {
                    settings.play()
                    if success {
                        appViewModel.addCoins(MiniGameType.memoryCards.reward)
                    }
                    appViewModel.navigateTo(.miniGames)
                }
                
                MainButtonView(
                    label: "Play again",
                    labelSize: min(geometry.size.width * 0.022, 18),
                    width: min(geometry.size.width * 0.22, 180),
                    height: min(geometry.size.width * 0.068, 55)
                ) {
                    settings.play()
                    viewModel.resetGame()
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
    
    private func timeFormatted(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%01d:%02d", mins, secs)
    }
}

struct MemoryCardView: View {
    let card: MemoryCard
    let onTap: () -> Void
    let isInteractionDisabled: Bool
    let geometry: GeometryProxy
    
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var flipped: Bool = false
    
    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                // Card back
                Image(.buttonGroup3)
                    .resizable()
                
                // Card front
                if let cardImage = MemoryCardImage(rawValue: card.imageIdentifier) {
                    Image(.buttonGroup3)
                        .resizable()
                        .overlay(
                            Image(cardImage.imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(14)
                                .opacity(rotation >= 90 ? 1.0 : 0.0)
                                .offset(y: -2)
                        )
                }
            }
            .scaleEffect(scale)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .buttonStyle(.plain)
        .disabled(isInteractionDisabled)
        .onAppear {
            flipped = card.state != .down
            rotation = flipped ? 180 : 0
            scale = card.state == .matched ? 0.95 : 1.0
        }
        .onChange(of: card.state) { newState in
            switch newState {
            case .down:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotation = 0
                    flipped = false
                }
            case .up:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotation = 180
                    flipped = true
                }
            case .matched:
                withAnimation(.easeInOut(duration: 0.3)) {
                    rotation = 180
                    flipped = true
                    scale = 0.9
                }
            }
        }
    }
}

#Preview {
    MemoryGameView()
        .environmentObject(AppViewModel())
}

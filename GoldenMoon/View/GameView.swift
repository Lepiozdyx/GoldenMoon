//
//  GameView.swift
//  GoldenMoon

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: MillGameViewModel
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
            
            // Верхняя информационная панель
            VStack {
                HStack {
                    Text(viewModel.getPhaseText())
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(viewModel.getCurrentPlayerName())
                        .font(.headline)
                        .foregroundColor(viewModel.game.currentPlayer == .player1 ? .red : .blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        )
                    
                    Spacer()
                    
                    Text(viewModel.getActionText())
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding()
            
            HStack(spacing: 0) {
                // Левая панель фишек (игрок)
                if viewModel.game.phase == .placement {
                    SidePiecesView(
                        player: .player1,
                        piecesCount: 9 - viewModel.game.player1PlacedPieces,
                        pieceSize: 18
                    )
                }
                
                Spacer()
                
                // Правая панель фишек (оппонент)
                if viewModel.game.phase == .placement {
                    SidePiecesView(
                        player: .player2,
                        piecesCount: 9 - viewModel.game.player2PlacedPieces,
                        pieceSize: 18
                    )
                }
            }
            
            // Игровое поле
            GameBoardView(viewModel: viewModel, onNodeTap: { nodeId in
                viewModel.handleNodeTap(nodeId)
            })
            .padding()
            
            // Нижняя панель с кнопками
            VStack {
                Spacer()
                HStack {
                    // Счетчики фишек
                    VStack(alignment: .leading) {
                        Text("Your pieces: \(viewModel.game.player1Pieces)")
                            .foregroundColor(.white)
                        Text("Opponent's pieces: \(viewModel.game.player2Pieces)")
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Кнопки
                    Button(action: {
                        viewModel.pauseGame()
                    }) {
                        Text("BACK")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                            )
                    }
                    
                    Button(action: {
                        viewModel.game.resetGame()
                    }) {
                        Text("GIVE UP")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding()
            
            // Оверлеи
            if viewModel.isPaused {
                PauseOverlayView()
            }
            
            if viewModel.showVictoryOverlay {
                VictoryOverlayView()
            }
            
            if viewModel.showDefeatOverlay {
                DefeatOverlayView()
            }
        }
    }
}

#Preview {
    GameView(viewModel: MillGameViewModel())
        .environmentObject(AppViewModel())
}

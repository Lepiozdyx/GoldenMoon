//
//  GameView.swift
//  GoldenMoon

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: MillGameViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            BackgroundView(name: .bgimg1)
            
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
            
            // Панель фишек
            VStack {
                Spacer()
                
                HStack {
                    // Левая панель фишек (игрок 1)
                    if viewModel.game.phase == .placement {
                        SidePiecesView(
                            player: .player1,
                            piecesCount: 9 - viewModel.game.player1PlacedPieces,
                            pieceSize: 18,
                            gameMode: viewModel.game.gameMode  // Передаем режим игры
                        )
                    }
                    
                    Spacer()
                    
                    // Правая панель фишек (игрок 2)
                    if viewModel.game.phase == .placement {
                        SidePiecesView(
                            player: .player2,
                            piecesCount: 9 - viewModel.game.player2PlacedPieces,
                            pieceSize: 18,
                            gameMode: viewModel.game.gameMode  // Передаем режим игры
                        )
                    }
                }
            }
            .padding()
            
            // Игровое поле
            GameBoardView(viewModel: viewModel) { nodeId in
                viewModel.handleNodeTap(nodeId)
            }
            .frame(maxWidth: 450, maxHeight: 450)
            
            // Нижняя панель с кнопками
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    // Кнопки
                    MainButtonView(label: "Back", labelSize: 16, width: 100, height: 50) {
                        viewModel.pauseGame()
                    }
                    
                    Spacer()
                    
                    MainButtonView(label: "Give up", labelSize: 16, width: 100, height: 50) {
                        viewModel.game.resetGame()
                    }
                    
                    Spacer()
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

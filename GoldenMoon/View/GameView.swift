//
//  GameView.swift
//  GoldenMoon

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: MillGameViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            BackgroundView(name: appViewModel.currentBackground)
            
            // Верхняя информационная панель
            VStack {
                HStack {
                    Text(viewModel.getCurrentPlayerName())
                        .customFont(14)
                    
                    Spacer()
                    
                    Text(viewModel.getActionText())
                        .customFont(14)
                }
                
                Spacer()
            }
            .padding()
            
            // Панель фишек
            VStack {
                Spacer()
                
                HStack {
                    // Левая панель фишек (игрок 1)
                    if !viewModel.game.isAllPiecesPlaced() {
                        SidePiecesView(
                            player: .player1,
                            piecesCount: 9 - viewModel.game.player1PlacedPieces,
                            pieceSize: 18,
                            gameMode: viewModel.game.gameMode  // Передаем режим игры
                        )
                    }
                    
                    Spacer()
                    
                    // Правая панель фишек (игрок 2)
                    if !viewModel.game.isAllPiecesPlaced() {
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
            
            // Туториал оверлей
            if viewModel.showTutorial {
                TutorialView(
                    showTutorial: $viewModel.showTutorial,
                    gameMode: viewModel.game.gameMode
                )
                .transition(.opacity)
                .zIndex(101)
            }
        }
        .onReceive(viewModel.$showTutorial) { isShowing in
            // Проверяем, что туториал только что был закрыт
            if !isShowing && !UserDefaults.standard.bool(forKey: "goldenMoon.tutorialCompleted") {
                // Туториал завершен, начисляем награду
                appViewModel.completeTutorial()
                appViewModel.coins += 100
                appViewModel.saveGameState()
            }
        }
    }
}

#Preview {
    GameView(viewModel: MillGameViewModel())
        .environmentObject(AppViewModel())
}

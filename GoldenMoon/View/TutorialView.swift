//
//  TutorialView.swift
//  GoldenMoon

import SwiftUI

struct TutorialView: View {
    @Binding var showTutorial: Bool
    @State private var currentTipIndex: Int = 0
    let gameMode: MillGameMode
    
    let tutorialTips: [String] = [
        "Welcome to Golden Moon Games! In this game, you are trying to create \"mills\" (3 pieces in a row) while blocking your opponent.",
        "Phase 1: PLACEMENT - Take turns placing your pieces on empty points. Each player has 9 pieces to place.",
        "When you form a mill (3 in a row), you can remove one of your opponent's pieces! But you cannot remove pieces from an opponent's mill unless they only have mills.",
        "Phase 2: MOVEMENT - Once all pieces are placed, take turns moving your pieces along the lines to adjacent empty points.",
        "Continue forming mills and removing opponent's pieces. The goal is to reduce your opponent to 2 pieces or block all their moves.",
        "Phase 3: FLYING - When a player has only 3 pieces left, they can jump to any empty point on the board!",
        "Win by reducing your opponent to 2 pieces or by blocking all their possible moves. Good luck!"
    ]
    
    let aiSpecificTips: [String] = [
        "You're playing against the AI. The AI will think strategically to form mills and block your moves.",
        "Watch out - the AI will try to create and block mills. Think ahead!"
    ]
    
    var isLastTip: Bool {
        let totalTips = tutorialTips.count + (gameMode == .vsAI ? aiSpecificTips.count : 0)
        return currentTipIndex >= totalTips - 1
    }
    
    var currentTip: String {
        if currentTipIndex < tutorialTips.count {
            return tutorialTips[currentTipIndex]
        } else if gameMode == .vsAI {
            let aiTipIndex = currentTipIndex - tutorialTips.count
            return aiSpecificTips[aiTipIndex]
        }
        return ""
    }
    
    var body: some View {
        HStack {
            VStack {
                Image(.frame)
                    .resizable()
                    .frame(width: 300, height: 200)
                    .overlay {
                        VStack(spacing: 10) {
                            Text("Tutorial")
                                .customFont(16)
                            
                            Text(currentTip)
                                .customFont(12)
                        }
                        .padding(20)
                    }
                    .overlay(alignment: .topTrailing) {
                        if !isLastTip {
                            Button {
                                // Skip tutorial
                                showTutorial = false
                            } label: {
                                Image(.redsquare)
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .overlay {
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.white)
                                    }
                            }
                        }
                    }
                
                MainButtonView(
                    label: isLastTip ? "Start" : "Next",
                    labelSize: 16,
                    width: 120,
                    height: 50
                ) {
                    if isLastTip {
                        showTutorial = false
                    } else {
                        withAnimation {
                            currentTipIndex += 1
                        }
                    }
                }
                
                Spacer()
            }
            .transition(.opacity)
            
            Spacer()
        }
        .padding([.leading, .top])
    }
}

#Preview {
    TutorialView(showTutorial: .constant(true), gameMode: .vsAI)
}

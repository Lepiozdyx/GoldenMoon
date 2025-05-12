//
//  SequenceGameViewModel.swift
//  GoldenMoon
//
//  Created by Alex on 11.05.2025.
//

import SwiftUI
import Combine

class SequenceGameViewModel: ObservableObject {
    @Published private(set) var gameState: SequenceGameState = .showing
    @Published private(set) var sequence: [SequenceImage] = []
    @Published private(set) var currentShowingImage: SequenceImage?
    @Published private(set) var playerInput: [SequenceImage] = []
    @Published private(set) var currentSequenceLength: Int
    
    private var showImageTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var showingImageIndex = 0
    
    init() {
        currentSequenceLength = SequenceGameConstants.initialSequenceLength
        startNewGame()
    }
    
    func startNewGame() {
        cleanupTimers()
        sequence = generateSequence(length: currentSequenceLength)
        playerInput = []
        gameState = .showing
        showSequence()
    }
    
    func selectImage(_ image: SequenceImage) {
        guard gameState == .playing else { return }
        
        playerInput.append(image)
        
        let inputIndex = playerInput.count - 1
        if inputIndex < sequence.count && playerInput[inputIndex].imageName == sequence[inputIndex].imageName {
            if playerInput.count == sequence.count {
                handleSuccessfulRound()
            }
        } else {
            handleGameOver()
        }
    }
    
    func nextRound() {
        currentSequenceLength += 1
        startNewGame()
    }
    
    func restartAfterGameOver() {
        currentSequenceLength = SequenceGameConstants.initialSequenceLength
        startNewGame()
    }
    
    private func generateSequence(length: Int) -> [SequenceImage] {
        var newSequence: [SequenceImage] = []
        
        for _ in 0..<length {
            newSequence.append(SequenceImage.random())
        }
        
        return newSequence
    }
    
    private func showSequence() {
        showingImageIndex = 0
        showNextImageInSequence()
    }
    
    private func showNextImageInSequence() {
        guard showingImageIndex < sequence.count else {
            finishShowingSequence()
            return
        }
        
        currentShowingImage = sequence[showingImageIndex]
        showImageTimer = Timer.publish(every: SequenceGameConstants.showImageDuration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.showImageTimer?.cancel()
                self.showingImageIndex += 1
                self.showNextImageInSequence()
            }
    }
    
    private func finishShowingSequence() {
        currentShowingImage = nil
        gameState = .playing
    }
    
    private func handleSuccessfulRound() {
        gameState = .success
    }
    
    private func handleGameOver() {
        gameState = .gameOver
    }
    
    private func cleanupTimers() {
        showImageTimer?.cancel()
    }
    
    deinit {
        cleanupTimers()
    }
}

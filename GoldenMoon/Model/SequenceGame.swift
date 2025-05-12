//
//  SequenceGame.swift
//  GoldenMoon

import SwiftUI

enum SequenceGameConstants {
    static let initialSequenceLength = 2
    static let showImageDuration: TimeInterval = 1.0
    static let successDuration: TimeInterval = 1.5
    static let availableImages = [
        "sequence_1", "sequence_2", "sequence_3", "sequence_4",
        "sequence_5", "sequence_6", "sequence_7", "sequence_8"
    ]
}

enum SequenceGameState: Equatable {
    case showing
    case playing
    case success
    case gameOver
}

struct SequenceImage: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    
    static func random() -> SequenceImage {
        let randomIndex = Int.random(in: 0..<SequenceGameConstants.availableImages.count)
        return SequenceImage(imageName: SequenceGameConstants.availableImages[randomIndex])
    }
    
    static func == (lhs: SequenceImage, rhs: SequenceImage) -> Bool {
        return lhs.imageName == rhs.imageName
    }
}

//
//  Achievement.swift
//  GoldenMoon

import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let image: ImageResource
    let title: String
    let description: String
    
    static let all: [Achievement] = [
        Achievement(
            id: "all_backgrounds",
            image: .achi1,
            title: "Background Collector",
            description: "Purchase all backgrounds"
        ),
        Achievement(
            id: "ten_matches",
            image: .achi2,
            title: "Veteran Player",
            description: "Play 10 matches"
        ),
        Achievement(
            id: "rich_player",
            image: .achi3,
            title: "Wealthy Player",
            description: "Reach 10000 coins"
        ),
        Achievement(
            id: "all_chips",
            image: .achi4,
            title: "Chip Collector",
            description: "Purchase all chip skins"
        )
    ]
}

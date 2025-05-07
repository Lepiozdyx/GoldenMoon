//
//  MillNode.swift
//  GoldenMoon

import Foundation
import SwiftUI

struct MillNode: Identifiable, Equatable, Hashable {
    let id: Int
    let position: CGPoint
    let connections: [Int]
    
    var piece: MillPiece?
    var isHighlighted: Bool = false
    
    static func == (lhs: MillNode, rhs: MillNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

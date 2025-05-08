//
//  ScoreboardView.swift
//  GoldenMoon
//
//  Created by Alex on 08.05.2025.
//

import SwiftUI

struct ScoreboardView: View {
    let amount: Int
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Image(.underlayGroup)
                .resizable()
                .frame(width: 140, height: 50)
                .overlay {
                    Text("\(amount)")
                        .customFont(16)
                        .offset(x: -15)
                }
            
            Image(.coin)
                .resizable()
                .frame(width: 60, height: 60)
                .offset(x: 9)
        }
    }
}

#Preview {
    ScoreboardView(amount: 1999)
}

//
//  MainButtonView.swift
//  GoldenMoon
//
//  Created by Alex on 08.05.2025.
//

import SwiftUI

struct MainButtonView: View {
    let label: String
    let labelSize: CGFloat
    var width: CGFloat = 195
    var height: CGFloat = 75
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(.buttonGroup2)
                .resizable()
                .frame(width: width, height: height)
                .overlay {
                    Text(label)
                        .customFont(labelSize)
                        .offset(y: -5)
                        .padding(.horizontal)
                }
        }
    }
}

#Preview {
    MainButtonView(label: "Play", labelSize: 24, action: {})
}

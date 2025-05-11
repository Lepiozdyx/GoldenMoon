//
//  Extensions.swift
//  GoldenMoon

import SwiftUI

extension Text {
    func customFont(_ size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .heavy, design: .default))
            .foregroundStyle(.white)
            .shadow(color: .black, radius: 1, x: 2, y: 2)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}

struct TextExtension: View {
    var body: some View {
        ZStack {
            Color.secondary.ignoresSafeArea()
            
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .customFont(40)
        }
    }
}

#Preview {
    TextExtension()
}

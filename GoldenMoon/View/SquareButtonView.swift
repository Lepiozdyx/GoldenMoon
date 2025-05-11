//
//  SquareButtonView.swift
//  GoldenMoon

import SwiftUI

struct SquareButtonView: View {
    let image: ImageResource
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(.buttonGroup1)
                .resizable()
                .frame(width: 75, height: 75)
                .overlay {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
        }
    }
}

#Preview {
    SquareButtonView(image: .gear, action: {})
}

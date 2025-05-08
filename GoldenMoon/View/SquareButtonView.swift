//
//  SquareButtonView.swift
//  GoldenMoon
//
//  Created by Alex on 08.05.2025.
//

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

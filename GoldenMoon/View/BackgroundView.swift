//
//  BackgroundView.swift
//  GoldenMoon
//
//  Created by Alex on 08.05.2025.
//

import SwiftUI

struct BackgroundView: View {
    let name: ImageResource
    
    var body: some View {
        Image(name)
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView(name: .bgimg1)
}

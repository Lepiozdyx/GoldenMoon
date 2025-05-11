//
//  BackgroundView.swift
//  GoldenMoon

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

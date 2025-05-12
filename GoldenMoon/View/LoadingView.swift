//
//  LoadingView.swift
//  GoldenMoon

import SwiftUI

struct LoadingView: View {
    @State private var loading: CGFloat = 0
    
    var body: some View {
        ZStack {
            BackgroundView(name: .bgimg0)
            
            VStack {
                Spacer()
                
                Image(.emblem)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                
                Spacer()
                
                Text("Play your favorite games!")
                    .customFont(32)
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Loading")
                        .customFont(20)
                    
                    Image(.buttonGroup2)
                        .resizable()
                        .frame(maxWidth: 220, maxHeight: 64)
                        .foregroundStyle(.primary)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .frame(width: 191 * loading, height: 42)
                                .offset(x: -3, y: -3)
                                .foregroundStyle(.green)
                                .padding()
                        }
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.3)) {
                loading = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}

//
//  LoadingView.swift
//  GoldenMoon
//
//  Created by Alex on 08.05.2025.
//

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
                        .frame(maxWidth: 280, maxHeight: 60)
                        .foregroundStyle(.primary)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 242, height: 32)
                                .offset(y: -2)
                                .foregroundStyle(.asphalt)
                                .padding()
                        }
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 242 * loading, height: 32)
                                .offset(y: -2)
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

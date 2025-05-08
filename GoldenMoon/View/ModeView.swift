//
//  ModeView.swift
//  GoldenMoon
//
//  Created by Alex on 08.05.2025.
//

import SwiftUI

struct ModeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            BackgroundView(name: .bgimg1)
            
            VStack {
                Image(.labelGroup)
                    .resizable()
                    .frame(width: 180, height: 75)
                    .overlay {
                        Text("Mode")
                            .customFont(28)
                    }
                
                Spacer()
            }
            .padding()
            
            VStack {
                HStack {
                    SquareButtonView(image: .arrow) {
                        //                        svm.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
            
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    MainButtonView(label: "Solo", labelSize: 20) {
    //                    svm.play()
                        appViewModel.startGame(mode: .vsAI)
                    }
                    
                    MainButtonView(label: "Two Players", labelSize: 20) {
    //                    svm.play()
                        appViewModel.startGame(mode: .twoPlayers)
                    }
                }
                
                MainButtonView(label: "Tutorial", labelSize: 20) {
//                    svm.play()
                    appViewModel.startGame(mode: .tutorial)
                }
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    ModeView()
        .environmentObject(AppViewModel())
}

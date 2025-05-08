//
//  MenuView.swift
//  GoldenMoon

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            BackgroundView(name: .bgimg1)
            
            EmblemView()
            
            SidebarView()
            
            VStack(spacing: 15) {
                Spacer()
                
                MainButtonView(label: "Play", labelSize: 20) {
//                    svm.play()
//                    appViewModel.navigateTo(.mode)
                }
                
                MainButtonView(label: "Achieve", labelSize: 20) {
//                    svm.play()
//                    appViewModel.navigateTo(.achieve)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}

struct EmblemView: View {
    var body: some View {
        VStack {
            Image(.emblem)
                .resizable()
                .scaledToFit()
                .frame(height: 110)
            
            Spacer()
        }
        .padding()
    }
}

struct SidebarView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                SquareButtonView(image: .gear) {
                    //                        svm.play()
                    appViewModel.navigateTo(.settings)
                }
                
                Spacer()
                
                ScoreboardView(amount: appViewModel.coins)
            }
            
            Spacer()
            
            HStack {
                SquareButtonView(image: .joystick) {
                    //                        svm.play()
                    //                        appViewModel.navigateTo(.minigames)
                }
                
                SquareButtonView(image: .i) {
                    //                        svm.play()
                    //                        appViewModel.navigateTo(.daily)
                }
                
                Spacer()
                
                SquareButtonView(image: .shop) {
                    //                        svm.play()
                    //                        appViewModel.navigateTo(.shop)
                }
            }
        }
        .padding()
    }
}

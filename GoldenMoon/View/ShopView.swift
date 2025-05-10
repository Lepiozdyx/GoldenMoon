//
//  ShopView.swift
//  GoldenMoon
//
//  Created by Alex on 10.05.2025.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            BackgroundView(name: .bgimg1)
            
            VStack {
                HStack(alignment: .top) {
                    SquareButtonView(image: .arrow) {
                        settings.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    Image(.labelGroup)
                        .resizable()
                        .frame(width: 180, height: 75)
                        .overlay {
                            Text("Shop")
                                .customFont(28)
                        }
                    
                    Spacer()
                    
                    ScoreboardView(amount: appViewModel.coins)
                }
                
                Spacer()
                
                VStack(spacing: 30) {
                    HStack(spacing: 10) {
                        Image(.paper)
                            .resizable()
                            .frame(width: 80, height: 70)
                            .overlay {
                                Image(.bgimg1)
                                    .resizable()
                                    .padding(10)
                            }
                            .overlay(alignment: .bottom) {
                                MainButtonView(label: "use", labelSize: 12, width: 60, height: 30) {
                                    //
                                }
                                .offset(x: 0, y: 20)
                            }
                        
                        Image(.paper)
                            .resizable()
                            .frame(width: 80, height: 70)
                            .overlay {
                                Image(.bgimg0)
                                    .resizable()
                                    .padding(10)
                            }
                            .overlay(alignment: .bottom) {
                                MainButtonView(label: "100", labelSize: 12, width: 60, height: 30) {
                                    //
                                }
                                .offset(x: 0, y: 20)
                            }
                        
                        Image(.paper)
                            .resizable()
                            .frame(width: 80, height: 70)
                            .overlay {
                                Image(.bgimg2)
                                    .resizable()
                                    .padding(10)
                            }
                            .overlay(alignment: .bottom) {
                                MainButtonView(label: "100", labelSize: 12, width: 60, height: 30) {
                                    //
                                }
                                .offset(x: 0, y: 20)
                            }
                        
                        Image(.paper)
                            .resizable()
                            .frame(width: 80, height: 70)
                            .overlay {
                                Image(.bgimg3)
                                    .resizable()
                                    .padding(10)
                            }
                            .overlay(alignment: .bottom) {
                                MainButtonView(label: "100", labelSize: 12, width: 60, height: 30) {
                                    //
                                }
                                .offset(x: 0, y: 20)
                            }
                    }
                    
                    HStack(spacing: 10) {
                        Image(.paper)
                            .resizable()
                            .frame(width: 80, height: 70)
                            .overlay {
                                ZStack {
                                    Image(.chip1)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: -5, y: -5)
                                    
                                    Image(.chip11)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: 15, y: 15)
                                }
                                .padding(15)
                            }
                            .overlay(alignment: .bottom) {
                                MainButtonView(label: "use", labelSize: 12, width: 60, height: 30) {
                                    //
                                }
                                .offset(x: 0, y: 20)
                            }
                        
                        Image(.paper)
                            .resizable()
                            .frame(width: 80, height: 70)
                            .overlay {
                                ZStack {
                                    Image(.chip2)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: -5, y: -5)
                                    
                                    Image(.chip22)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: 15, y: 15)
                                }
                                .padding(15)
                            }
                            .overlay(alignment: .bottom) {
                                MainButtonView(label: "100", labelSize: 12, width: 60, height: 30) {
                                    //
                                }
                                .offset(x: 0, y: 20)
                            }
                        
                        Image(.paper)
                            .resizable()
                            .frame(width: 80, height: 70)
                            .overlay {
                                ZStack {
                                    Image(.chip3)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: -5, y: -5)
                                    
                                    Image(.chip33)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: 15, y: 15)
                                }
                                .padding(15)
                            }
                            .overlay(alignment: .bottom) {
                                MainButtonView(label: "100", labelSize: 12, width: 60, height: 30) {
                                    //
                                }
                                .offset(x: 0, y: 20)
                            }
                        
                        Image(.paper)
                            .resizable()
                            .frame(width: 80, height: 70)
                            .overlay {
                                ZStack {
                                    Image(.chip4)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: -5, y: -5)
                                    
                                    Image(.chip44)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: 15, y: 15)
                                }
                                .padding(15)
                            }
                            .overlay(alignment: .bottom) {
                                MainButtonView(label: "100", labelSize: 12, width: 60, height: 30) {
                                    //
                                }
                                .offset(x: 0, y: 20)
                            }
                    }
                }
                .padding(.horizontal, 80)
                .padding(.vertical, 40)
                .background(
                    Image(.frame)
                        .resizable()
                )
                
                Spacer()
            }
            .padding()
            
            
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}

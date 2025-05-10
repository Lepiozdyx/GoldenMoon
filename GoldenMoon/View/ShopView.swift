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
    @StateObject private var shopViewModel = ShopViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView(name: appViewModel.currentBackground)
            
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
                    // Фоны
                    HStack(spacing: 10) {
                        ForEach(shopViewModel.availableBackgrounds, id: \.image) { background in
                            BackgroundShopItem(
                                background: background.image,
                                price: background.price,
                                isPurchased: shopViewModel.purchasedBackgrounds.contains(background.image),
                                isSelected: shopViewModel.currentBackground == background.image,
                                canAfford: appViewModel.coins >= background.price,
                                onPurchase: {
                                    shopViewModel.purchaseBackground(background.image)
                                },
                                onSelect: {
                                    shopViewModel.selectBackground(background.image)
                                }
                            )
                        }
                    }
                    
                    // Фишки
                    HStack(spacing: 10) {
                        ForEach(Array(shopViewModel.availableChipSkins.enumerated()), id: \.offset) { index, skin in
                            ChipShopItem(
                                chipSkin: (skin.player1, skin.player2),
                                price: skin.price,
                                isPurchased: shopViewModel.purchasedChipSkins.contains { $0.player1 == skin.player1 && $0.player2 == skin.player2 },
                                isSelected: shopViewModel.currentChipSkin.player1 == skin.player1 && shopViewModel.currentChipSkin.player2 == skin.player2,
                                canAfford: appViewModel.coins >= skin.price,
                                onPurchase: {
                                    shopViewModel.purchaseChipSkin((skin.player1, skin.player2))
                                },
                                onSelect: {
                                    shopViewModel.selectChipSkin((skin.player1, skin.player2))
                                }
                            )
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
        .onAppear {
            shopViewModel.appViewModel = appViewModel
        }
    }
}

struct BackgroundShopItem: View {
    let background: ImageResource
    let price: Int
    let isPurchased: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onPurchase: () -> Void
    let onSelect: () -> Void
    
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        Image(.paper)
            .resizable()
            .frame(width: 80, height: 70)
            .overlay {
                Image(background)
                    .resizable()
                    .padding(10)
            }
            .overlay(alignment: .bottom) {
                MainButtonView(
                    label: buttonLabel,
                    labelSize: 12,
                    width: 60,
                    height: 30
                ) {
                    settings.play()
                    if isPurchased {
                        if !isSelected {
                            onSelect()
                        }
                    } else if canAfford {
                        onPurchase()
                    }
                }
                .disabled(!canAfford && !isPurchased)
                .opacity(canAfford || isPurchased ? 1.0 : 0.6)
                .offset(x: 0, y: 20)
            }
    }
    
    private var buttonLabel: String {
        if isSelected {
            return "used"
        } else if isPurchased {
            return "use"
        } else {
            return "\(price)"
        }
    }
}

struct ChipShopItem: View {
    let chipSkin: (player1: ImageResource, player2: ImageResource)
    let price: Int
    let isPurchased: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onPurchase: () -> Void
    let onSelect: () -> Void
    
    @StateObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        Image(.paper)
            .resizable()
            .frame(width: 80, height: 70)
            .overlay {
                ZStack {
                    Image(chipSkin.player1)
                        .resizable()
                        .scaledToFit()
                        .offset(x: -5, y: -5)
                    
                    Image(chipSkin.player2)
                        .resizable()
                        .scaledToFit()
                        .offset(x: 15, y: 15)
                }
                .padding(15)
            }
            .overlay(alignment: .bottom) {
                MainButtonView(
                    label: buttonLabel,
                    labelSize: 12,
                    width: 60,
                    height: 30
                ) {
                    settings.play()
                    if isPurchased {
                        if !isSelected {
                            onSelect()
                        }
                    } else if canAfford {
                        onPurchase()
                    }
                }
                .disabled(!canAfford && !isPurchased)
                .opacity(canAfford || isPurchased ? 1.0 : 0.6)
                .offset(x: 0, y: 20)
            }
    }
    
    private var buttonLabel: String {
        if isSelected {
            return "used"
        } else if isPurchased {
            return "use"
        } else {
            return "\(price)"
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}

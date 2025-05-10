//
//  ShopViewModel.swift
//  GoldenMoon
//

import SwiftUI
import Combine

@MainActor
class ShopViewModel: ObservableObject {
    @Published var purchasedBackgrounds: [ImageResource] = []
    @Published var currentBackground: ImageResource = .bgimg1
    @Published var purchasedChipSkins: [(player1: ImageResource, player2: ImageResource)] = []
    @Published var currentChipSkin: (player1: ImageResource, player2: ImageResource) = (.chip1, .chip11)
    
    weak var appViewModel: AppViewModel?
    
    let availableBackgrounds: [(image: ImageResource, price: Int)] = [
        (.bgimg1, 0),
        (.bgimg0, 100),
        (.bgimg2, 100),
        (.bgimg3, 100)
    ]
    
    let availableChipSkins: [(player1: ImageResource, player2: ImageResource, price: Int)] = [
        (player1: .chip1, player2: .chip11, price: 0),
        (player1: .chip2, player2: .chip22, price: 100),
        (player1: .chip3, player2: .chip33, price: 100),
        (player1: .chip4, player2: .chip44, price: 100)
    ]
    
    private let purchasedBackgroundsKey = "goldenMoon.purchasedBackgrounds"
    private let currentBackgroundKey = "goldenMoon.currentBackground"
    private let purchasedChipSkinsKey = "goldenMoon.purchasedChipSkins"
    private let currentChipSkinKey = "goldenMoon.currentChipSkin"
    
    init() {
        loadPurchases()
    }
    
    private func loadPurchases() {
        // Загрузка купленных фонов
        if let data = UserDefaults.standard.data(forKey: purchasedBackgroundsKey),
           let backgrounds = try? JSONDecoder().decode([String].self, from: data) {
            self.purchasedBackgrounds = backgrounds.compactMap { imageResourceFromString($0) }
        } else {
            self.purchasedBackgrounds = [.bgimg1] // По умолчанию первый фон
        }
        
        // Загрузка текущего фона
        if let backgroundString = UserDefaults.standard.string(forKey: currentBackgroundKey),
           let background = imageResourceFromString(backgroundString) {
            self.currentBackground = background
        }
        
        // Загрузка купленных скинов фишек
        if let data = UserDefaults.standard.data(forKey: purchasedChipSkinsKey),
           let skinPairs = try? JSONDecoder().decode([[String]].self, from: data) {
            self.purchasedChipSkins = skinPairs.compactMap { pair in
                if pair.count == 2,
                   let chip1 = imageResourceFromString(pair[0]),
                   let chip2 = imageResourceFromString(pair[1]) {
                    return (chip1, chip2)
                }
                return nil
            }
        } else {
            self.purchasedChipSkins = [(.chip1, .chip11)] // По умолчанию первая пара
        }
        
        // Загрузка текущего скина фишек
        if let data = UserDefaults.standard.data(forKey: currentChipSkinKey),
           let skinPair = try? JSONDecoder().decode([String].self, from: data),
           skinPair.count == 2,
           let chip1 = imageResourceFromString(skinPair[0]),
           let chip2 = imageResourceFromString(skinPair[1]) {
            self.currentChipSkin = (chip1, chip2)
        }
    }
    
    private func saveState() {
        // Сохранение купленных фонов
        let backgroundStrings = purchasedBackgrounds.map { stringFromImageResource($0) }
        if let data = try? JSONEncoder().encode(backgroundStrings) {
            UserDefaults.standard.set(data, forKey: purchasedBackgroundsKey)
        }
        
        // Сохранение текущего фона
        UserDefaults.standard.set(stringFromImageResource(currentBackground), forKey: currentBackgroundKey)
        
        // Сохранение купленных скинов
        let skinStrings = purchasedChipSkins.map { [stringFromImageResource($0.0), stringFromImageResource($0.1)] }
        if let data = try? JSONEncoder().encode(skinStrings) {
            UserDefaults.standard.set(data, forKey: purchasedChipSkinsKey)
        }
        
        // Сохранение текущего скина
        let currentSkinStrings = [stringFromImageResource(currentChipSkin.0), stringFromImageResource(currentChipSkin.1)]
        if let data = try? JSONEncoder().encode(currentSkinStrings) {
            UserDefaults.standard.set(data, forKey: currentChipSkinKey)
        }
        
        UserDefaults.standard.synchronize()
        
        // Обновляем AppViewModel
        if let appViewModel = appViewModel {
            appViewModel.currentBackground = currentBackground
            appViewModel.currentChipSkin = currentChipSkin
        }
    }
    
    func purchaseBackground(_ background: ImageResource) {
        guard let appViewModel = appViewModel,
              let backgroundData = availableBackgrounds.first(where: { $0.image == background }),
              appViewModel.coins >= backgroundData.price,
              !purchasedBackgrounds.contains(background) else { return }
        
        appViewModel.coins -= backgroundData.price
        appViewModel.saveGameState()
        
        purchasedBackgrounds.append(background)
        currentBackground = background
        
        saveState()
    }
    
    func selectBackground(_ background: ImageResource) {
        guard purchasedBackgrounds.contains(background) else { return }
        currentBackground = background
        saveState()
    }
    
    func purchaseChipSkin(_ skin: (player1: ImageResource, player2: ImageResource)) {
        guard let appViewModel = appViewModel,
              let skinData = availableChipSkins.first(where: { $0.player1 == skin.player1 && $0.player2 == skin.player2 }),
              appViewModel.coins >= skinData.price,
              !purchasedChipSkins.contains(where: { $0.player1 == skin.player1 && $0.player2 == skin.player2 }) else { return }
        
        appViewModel.coins -= skinData.price
        appViewModel.saveGameState()
        
        purchasedChipSkins.append(skin)
        currentChipSkin = skin
        
        saveState()
    }
    
    func selectChipSkin(_ skin: (player1: ImageResource, player2: ImageResource)) {
        guard purchasedChipSkins.contains(where: { $0.player1 == skin.player1 && $0.player2 == skin.player2 }) else { return }
        currentChipSkin = skin
        saveState()
    }
    
    // Вспомогательные функции для конвертации ImageResource в String и обратно
    private func stringFromImageResource(_ resource: ImageResource) -> String {
        switch resource {
        case .bgimg0: return "bgimg0"
        case .bgimg1: return "bgimg1"
        case .bgimg2: return "bgimg2"
        case .bgimg3: return "bgimg3"
        case .chip1: return "chip1"
        case .chip11: return "chip11"
        case .chip2: return "chip2"
        case .chip22: return "chip22"
        case .chip3: return "chip3"
        case .chip33: return "chip33"
        case .chip4: return "chip4"
        case .chip44: return "chip44"
        default: return "unknown"
        }
    }
    
    private func imageResourceFromString(_ string: String) -> ImageResource? {
        switch string {
        case "bgimg0": return .bgimg0
        case "bgimg1": return .bgimg1
        case "bgimg2": return .bgimg2
        case "bgimg3": return .bgimg3
        case "chip1": return .chip1
        case "chip11": return .chip11
        case "chip2": return .chip2
        case "chip22": return .chip22
        case "chip3": return .chip3
        case "chip33": return .chip33
        case "chip4": return .chip4
        case "chip44": return .chip44
        default: return nil
        }
    }
}

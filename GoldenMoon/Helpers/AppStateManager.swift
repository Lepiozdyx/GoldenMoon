//
//  AppStateViewModel.swift
//  GoldenMoon

import Foundation

@MainActor
final class AppStateManager: ObservableObject {
    enum AppState {
        case initial
        case fetch
        case final
    }
    
    @Published private(set) var appState: AppState = .initial
    let webManager: NetworkManager
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func stateCheck() {
        Task {
            if webManager.targetURL != nil {
                appState = .fetch
                return
            }
            
            do {
                if try await webManager.checkInitialURL() {
                    appState = .fetch
                } else {
                    appState = .final
                }
            } catch {
                appState = .final
            }
        }
    }
}

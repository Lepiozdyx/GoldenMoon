//
//  RootView.swift
//  GoldenMoon

import SwiftUI

struct RootView: View {
    @StateObject private var state = AppStateManager()
    private var orientation = OrientationManager.shared
    
    var body: some View {
        Group {
            switch state.appState {
            case .initial:
                LoadingView()
            case .fetch:
                if let url = state.webManager.targetURL {
                    WebViewManager(url: url, webManager: state.webManager)
                        .onAppear {
                            orientation.unlockOrientation()
                        }
                } else {
                    WebViewManager(url: NetworkManager.initialURL, webManager: state.webManager)
                        .onAppear {
                            orientation.unlockOrientation()
                        }
                }
            case .final:
                ContentView()
            }
        }
        .onAppear {
            state.stateCheck()
        }
    }
}

#Preview {
    RootView()
}

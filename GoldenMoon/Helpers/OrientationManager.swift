//
//  OrientationManager.swift
//  GoldenMoon

import SwiftUI

class OrientationManager {
    
    static let shared = OrientationManager()
    
    private init() {}
    
    func unlockOrientation() {
        OrientationHelper.orientationMask = .all
        OrientationHelper.isAutoRotationEnabled = true
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func lockLandscape() {
        OrientationHelper.orientationMask = .landscape
        OrientationHelper.isAutoRotationEnabled = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if windowScene.interfaceOrientation.isPortrait {
                OrientationHelper.isAutoRotationEnabled = true
                UIViewController.attemptRotationToDeviceOrientation()
                
                if #available(iOS 16.0, *) {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                } else {
                    UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
                
                OrientationHelper.isAutoRotationEnabled = false
            }
        }
    }
}

class OrientationHelper {
    public static var orientationMask: UIInterfaceOrientationMask = .landscapeLeft
    public static var isAutoRotationEnabled: Bool = false
}

class CustomHostingController<Content: View>: UIHostingController<Content> {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OrientationHelper.orientationMask
    }

    override var shouldAutorotate: Bool {
        return OrientationHelper.isAutoRotationEnabled
    }
}

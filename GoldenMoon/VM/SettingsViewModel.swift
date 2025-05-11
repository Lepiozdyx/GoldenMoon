//
//  SettingsViewModel.swift
//  GoldenMoon

import SwiftUI
import AVFoundation

@MainActor class SettingsViewModel: ObservableObject {
    
    static let shared = SettingsViewModel()
    
    @Published var isSoundOn: Bool {
        didSet {
            defaults.set(isSoundOn, forKey: soundKey)
            
            if !isSoundOn && isMusicOn {
                isMusicOn = false
            }
        }
    }
    
    @Published var isMusicOn: Bool {
        didSet {
            defaults.set(isMusicOn, forKey: musicKey)
            
            if isMusicOn {
                if isSoundOn {
                    playMusic()
                } else {
                    isMusicOn = false
                }
            } else {
                stopMusic()
            }
        }
    }
    
    private let defaults = UserDefaults.standard
    private var audioPlayer: AVAudioPlayer?
    private var soundPlayer: AVAudioPlayer?
    
    private let soundKey = "appsound"
    private let musicKey = "appmusic"
    
    private let soundName = "click"
    private let musicName = "theme"
    
    private init() {
        self.isSoundOn = true
        self.isMusicOn = true
        
        if defaults.object(forKey: soundKey) != nil {
            self.isSoundOn = defaults.bool(forKey: soundKey)
        } else {
            defaults.set(true, forKey: soundKey)
        }
        
        if defaults.object(forKey: musicKey) != nil {
            self.isMusicOn = defaults.bool(forKey: musicKey)
        } else {
            defaults.set(true, forKey: musicKey)
        }
        
        setupAudio()
        fetchMusic()
        fetchSound()
    }
    
    func toggleSound() {
        isSoundOn.toggle()
    }
    
    func toggleMusic() {
        if !isSoundOn && !isMusicOn {
            return
        }
        isMusicOn.toggle()
    }
    
    func play() {
        guard isSoundOn, let player = soundPlayer else { return }
        player.currentTime = 0
        player.play()
    }
    
    func playMusic() {
        guard isSoundOn, isMusicOn, let player = audioPlayer, !player.isPlaying else { return }
        player.play()
    }
    
    func stopMusic() {
        audioPlayer?.pause()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    private func fetchSound() {
        guard let url = Bundle.main.url(
            forResource: soundName,
            withExtension: "mp3"
        ) else { return }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchMusic() {
        guard let url = Bundle.main.url(
            forResource: musicName,
            withExtension: "mp3"
        ) else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
}

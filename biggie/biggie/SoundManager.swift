import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var isMuted = false
    
    private init() {
        preloadSounds()
    }
    
    private func preloadSounds() {
        let soundNames = [
            "goal_complete": "goal_complete",
            "reward_earned": "reward_earned",
            "button_tap": "button_tap",
            "success": "success"
        ]
        
        for (key, name) in soundNames {
            if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[key] = player
                } catch {
                    print("Could not load sound: \(name)")
                }
            }
        }
    }
    
    func playSound(_ name: String) {
        guard !isMuted else { return }
        
        if let player = audioPlayers[name] {
            player.currentTime = 0
            player.play()
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    func isSoundMuted() -> Bool {
        return isMuted
    }
}

// Sound effect names
extension SoundManager {
    static let goalComplete = "goal_complete"
    static let rewardEarned = "reward_earned"
    static let buttonTap = "button_tap"
    static let success = "success"
} 
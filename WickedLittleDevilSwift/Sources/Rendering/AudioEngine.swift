import AVFoundation
import Foundation
import AudioToolbox

/// Lightweight audio helper for menu music.
final class AudioEngine {
    static let shared = AudioEngine()

    var isMuted = false {
        didSet { if isMuted { stopMusic() } }
    }

    private var music: AVAudioPlayer?
    /// The track currently loaded, so repeat requests for the same music (menu
    /// navigation, returning from a run) let it keep playing instead of
    /// restarting it from the top.
    private(set) var currentTrack: String?

    private init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    func playMusic(_ name: String, loop: Bool = true) {
        guard !isMuted else { return }
        guard currentTrack != name || music?.isPlaying != true else { return }
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "aifc" : (name as NSString).pathExtension
        guard let url = AssetLocator.url(forResource: base, withExtension: ext),
              let player = try? AVAudioPlayer(contentsOf: url)
        else { return }

        music?.stop()
        player.numberOfLoops = loop ? -1 : 0
        player.volume = 0.6
        player.prepareToPlay()
        player.play()
        music = player
        currentTrack = name
    }

    func stopMusic() {
        music?.stop()
        music = nil
        currentTrack = nil
    }

    func preloadEffects(_ names: [String]) {
        for name in names {
            _ = effectPlayer(for: name)
        }
    }

    func playEffect(_ name: String) {
        guard !isMuted, let player = effectPlayer(for: name) else { return }
        player.currentTime = 0
        player.play()
    }

    func playSystemEffect(_ soundID: SystemSoundID) {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(soundID)
    }

    private var effectPlayers: [String: AVAudioPlayer] = [:]

    private func effectPlayer(for name: String) -> AVAudioPlayer? {
        if let cached = effectPlayers[name] { return cached }
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "caf" : (name as NSString).pathExtension
        guard let url = AssetLocator.url(forResource: base, withExtension: ext),
              let player = try? AVAudioPlayer(contentsOf: url)
        else { return nil }
        player.prepareToPlay()
        effectPlayers[name] = player
        return player
    }
}

enum SoundEffect {
    static let jumpNormal = "jump1.caf"
    static let jumpBoost = "jump4.caf"
    static let jumpBreakable = "jump2.caf"
    static let complete = "complete.caf"
    static let collectSmall = "collect-small.caf"
    static let halo = "harp.caf"
    static let batHit = "bat-hit.caf"
    static let boom = "boom.caf"
    static let bubble = "bubble.caf"
    static let playerHit = "player-hit.caf"
    static let click = "click.caf"

    static func bigCollect(index: Int) -> String {
        "collect\(min(max(index, 1), 3)).caf"
    }

    static let all: [String] = [
        jumpNormal, jumpBoost, jumpBreakable, complete, collectSmall, halo,
        batHit, boom, bubble, playerHit, click,
        bigCollect(index: 1), bigCollect(index: 2), bigCollect(index: 3),
    ]
}

enum MusicTrack {
    /// `StartScene.m` / `GameOverScene.m` — the menus' track.
    static let menu = "bg-main.aifc"
    /// `AdventureSelectScene.m` — the detective campaign's track.
    static let detective = "detective-music.aifc"
}

enum SystemSoundEffect {
    static let collectSoul: SystemSoundID = 1104
}

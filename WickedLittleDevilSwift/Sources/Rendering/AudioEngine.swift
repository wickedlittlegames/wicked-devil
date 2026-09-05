import AVFoundation
import Foundation

/// Replacement for cocos2d's `SimpleAudioEngine`.
///
/// The original `.caf` effects and `.aifc` music loops are natively supported
/// by `AVAudioPlayer`, so they are played straight from the bundle. Effects are
/// pooled per file so overlapping jumps and pickups do not cut each other off.
final class AudioEngine {
    static let shared = AudioEngine()

    var isMuted = false {
        didSet { if isMuted { stopMusic() } }
    }

    private var effectPools: [String: [AVAudioPlayer]] = [:]
    private var music: AVAudioPlayer?

    private init() {
        configureSession()
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        // `.ambient` keeps any music the player already has going, matching the
        // behaviour iOS games are expected to have.
        try? session.setCategory(.ambient, mode: .default)
        try? session.setActive(true)
    }

    // MARK: - Effects

    /// Preloads a set of effects so the first play does not hitch.
    func preloadEffects(_ names: [String]) {
        for name in names { _ = pool(for: name) }
    }

    func playEffect(_ name: String, gain: Float = 1.0) {
        guard !isMuted else { return }
        guard let players = pool(for: name) else { return }
        let player = players.first(where: { !$0.isPlaying }) ?? players[0]
        player.volume = gain
        player.currentTime = 0
        player.play()
    }

    private func pool(for name: String) -> [AVAudioPlayer]? {
        if let existing = effectPools[name] { return existing.isEmpty ? nil : existing }

        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "caf" : (name as NSString).pathExtension
        guard let url = AssetLocator.url(forResource: base, withExtension: ext) else {
            effectPools[name] = []
            return nil
        }

        var players: [AVAudioPlayer] = []
        for _ in 0..<3 {
            guard let player = try? AVAudioPlayer(contentsOf: url) else { break }
            player.prepareToPlay()
            players.append(player)
        }
        effectPools[name] = players
        return players.isEmpty ? nil : players
    }

    // MARK: - Music

    func playMusic(_ name: String, loop: Bool = true) {
        guard !isMuted else { return }
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
    }

    func stopMusic() {
        music?.stop()
        music = nil
    }
}

/// The effect filenames the gameplay layer triggers, from `Platform.m`,
/// `Enemy.m` and `GameLayer.m`.
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

    /// `collect1.caf` / `collect2.caf` / `collect3.caf`, chosen by how many big
    /// collectables the player has picked up.
    static func bigCollect(index: Int) -> String {
        "collect\(min(max(index, 1), 3)).caf"
    }

    static let all: [String] = [
        jumpNormal, jumpBoost, jumpBreakable, complete, collectSmall, halo,
        batHit, boom, bubble, playerHit, click,
        bigCollect(index: 1), bigCollect(index: 2), bigCollect(index: 3),
    ]
}

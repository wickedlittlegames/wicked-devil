import Foundation
import WickedDevilCore

/// Fixtures so every menu screen has a `#Preview` that runs entirely on
/// `InMemoryUserDataStore` — no `UserDefaults`, no gameplay, no device.
enum MenuPreview {
    /// A brand-new profile: world 1 level 1 only, no souls.
    static func freshModel() -> MenuModel {
        MenuModel(store: InMemoryUserDataStore(), inventory: .shipped)
    }

    /// Mid-game: three worlds open, plenty of souls, some upgrades owned.
    static func inProgressModel() -> MenuModel {
        let model = MenuModel(store: InMemoryUserDataStore(), inventory: .shipped)
        let user = model.user

        user.collected = 27_500
        user.worldProgress = 3
        user.levelProgress = 6
        user.deaths = 42
        user.jumps = 1_310

        // Everything in worlds 1 and 2, plus the first five of world 3.
        for world in 1...2 {
            for level in 1...GameConstants.levelsPerWorld {
                complete(user: user, world: world, level: level, souls: (level % 4), halo: level % 3 == 0)
            }
        }
        for level in 1...5 {
            complete(user: user, world: 3, level: level, souls: 2, halo: level.isMultiple(of: 2))
        }
        user.setGameProgress(world: 3, level: 6)

        user.buyItem(4)
        user.buyItem(13)
        user.buySpecialItem(2)
        user.buyCharacter(1)
        user.powerup = 13
        user.boughtPowerups = true
        user.character = 1
        user.boughtCharacter = true
        user.sync()
        _ = user.checkAchievements()

        model.refresh()
        return model
    }

    /// Everything unlocked, including the detective campaign.
    static func completedModel() -> MenuModel {
        let model = inProgressModel()
        let user = model.user
        user.collected = 120_000
        user.worldProgress = GameConstants.currentWorldsPerGame + 1
        user.levelProgress = GameConstants.levelsPerWorld
        for world in 1...GameConstants.currentWorldsPerGame {
            for level in 1...GameConstants.levelsPerWorld {
                complete(user: user, world: world, level: level, souls: 3, halo: true)
            }
        }
        for level in 1...10 {
            complete(user: user, world: GameConstants.detectiveWorld, level: level, souls: 3, halo: false)
        }
        user.sync()
        _ = user.unlockDetective()
        _ = user.checkAchievements()
        model.refresh()
        return model
    }

    private static func complete(user: User, world: Int, level: Int, souls: Int, halo: Bool) {
        user.setGameProgress(world: world, level: level)
        user.setHighscore(1_000 * level + souls * 800, world: world, level: level)
        user.setSouls(souls, world: world, level: level)
        if world != GameConstants.detectiveWorld {
            user.setHalos(halo ? 1 : 0, world: world, level: level)
        }
    }

    /// A winning run on world 2, level 7.
    static let sampleResult = GameResult(
        world: 2,
        level: 7,
        bigCollected: 2,
        collected: 47,
        haloCollected: 1,
        timeLimit: GameConstants.baseTimeLimitSeconds,
        timeTaken: 19,
        pointsPerCollectable: 10,
        didWin: true
    )

    static let sampleRequest = GameLaunchRequest(world: 2, level: 7, pastScore: 3_100)
}

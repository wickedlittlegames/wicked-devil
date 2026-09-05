import Foundation
import WickedDevilCore

/// A purchasable, equippable item.
///
/// The original loaded these from `Resources/DATA/Powerups.plist`,
/// `Powerups_special.plist` and `Characters.plist`. The three files are tiny,
/// never changed after ship, and are needed by both the shop screens and the
/// gameplay layer, so they are transcribed here verbatim rather than parsed at
/// runtime.
struct CatalogItem: Identifiable, Hashable, Sendable {
    /// Index into the matching `User` ownership array (`items`,
    /// `itemsSpecial` or `itemsCharacters`).
    let index: Int
    let name: String
    let detail: String
    let cost: Int
    /// Asset-catalog image name, where the original shipped artwork.
    let imageName: String?

    var id: Int { index }
}

/// The three shop catalogues, transcribed from the original plists.
enum MenuCatalog {

    /// `Powerups.plist` — "DEVIL UPGRADES". Equipping writes the index straight
    /// into `User.powerup`.
    static let powerups: [CatalogItem] = [
        CatalogItem(index: 0, name: "Lucky Devil I", detail: "Save yourself from falling x1", cost: 500, imageName: nil),
        CatalogItem(index: 1, name: "Lucky Devil II", detail: "Save yourself from falling x2", cost: 2_000, imageName: nil),
        CatalogItem(index: 2, name: "Lucky Devil III", detail: "Save yourself from falling x3", cost: 5_000, imageName: nil),
        CatalogItem(index: 3, name: "Lucky Devil IV", detail: "Save yourself from falling x10", cost: 15_000, imageName: nil),
        CatalogItem(index: 4, name: "Bouncy Devil I", detail: "Jump higher!", cost: 500, imageName: nil),
        CatalogItem(index: 5, name: "Bouncy Devil II", detail: "Jump even higher!", cost: 2_000, imageName: nil),
        CatalogItem(index: 6, name: "Bouncy Devil III", detail: "Jump highest!", cost: 5_000, imageName: nil),
        CatalogItem(index: 7, name: "Feather Devil I", detail: "+1 hits before breakable fall.", cost: 500, imageName: nil),
        CatalogItem(index: 8, name: "Feather Devil II", detail: "+2 hits before breakable fall.", cost: 2_000, imageName: nil),
        CatalogItem(index: 9, name: "Feather Devil III", detail: "+3 hits before breakable fall.", cost: 5_000, imageName: nil),
        CatalogItem(index: 10, name: "Quick Devil I", detail: "Move across the screen quicker.", cost: 500, imageName: nil),
        CatalogItem(index: 11, name: "Quick Devil II", detail: "Move quicker than Quick Devil I.", cost: 2_000, imageName: nil),
        CatalogItem(index: 12, name: "Quick Devil III", detail: "Move quicker than Quick Devil II.", cost: 5_000, imageName: nil),
        CatalogItem(index: 13, name: "Tough Devil I", detail: "Take +1 hit before you DIE.", cost: 500, imageName: nil),
        CatalogItem(index: 14, name: "Tough Devil II", detail: "Take +2 hits before you DIE.", cost: 2_500, imageName: nil),
        CatalogItem(index: 15, name: "Tough Devil III", detail: "Take +3 hits before you DIE.", cost: 5_000, imageName: nil),
        CatalogItem(index: 16, name: "Tough Devil IV", detail: "Indestructible Devil!", cost: 15_000, imageName: nil),
        CatalogItem(index: 17, name: "Winning Devil I", detail: "Small souls are worth 15 points each!", cost: 500, imageName: nil),
        CatalogItem(index: 18, name: "Winning Devil II", detail: "Small souls are worth 20 points each!", cost: 2_000, imageName: nil),
        CatalogItem(index: 19, name: "Winning Devil III", detail: "Small souls are worth 30 points each!", cost: 5_000, imageName: nil),
        CatalogItem(index: 20, name: "Rich Devil I", detail: "Small souls count as x2!", cost: 2_500, imageName: nil),
        CatalogItem(index: 21, name: "Rich Devil II", detail: "Small souls count as x3!", cost: 5_000, imageName: nil),
        CatalogItem(index: 22, name: "Rich Devil III", detail: "Small souls count as x5!", cost: 20_000, imageName: nil),
    ]

    /// `Powerups_special.plist` — "SPECIAL UPGRADES".
    static let specialPowerups: [CatalogItem] = [
        CatalogItem(index: 0, name: "Bound Platforms", detail: "Platforms no longer disappear!", cost: 10_000, imageName: nil),
        CatalogItem(index: 1, name: "Bubble Pop", detail: "Pop the floating bubbles", cost: 10_000, imageName: nil),
        CatalogItem(index: 2, name: "Soul Magnet", detail: "Small souls will fly towards you!", cost: 10_000, imageName: nil),
        CatalogItem(index: 3, name: "Soul Magnet II", detail: "Small souls will fly towards you!", cost: 20_000, imageName: nil),
        CatalogItem(index: 4, name: "It's a Dud!", detail: "Rockets no longer fire at you!", cost: 10_000, imageName: nil),
    ]

    /// `Characters.plist` — "CHARACTERS".
    static let characters: [CatalogItem] = [
        CatalogItem(index: 0, name: "Detective Devil", detail: "An echo of the Devils previous life...", cost: 2_500, imageName: "character-unlock-detective"),
        CatalogItem(index: 1, name: "Pixel Devil", detail: "16 bits of evil", cost: 2_500, imageName: "pixel-devil-store"),
        CatalogItem(index: 2, name: "Zombie Devil", detail: "The ultimate evil combination!", cost: 5_000, imageName: "zombie-devil"),
        CatalogItem(index: 3, name: "Ninja Devil", detail: "Stealthy Devil!", cost: 10_000, imageName: "ninjadevil-store"),
        CatalogItem(index: 4, name: "Pirate Devil", detail: "Yaaarrr!", cost: 10_000, imageName: "pirate-shop"),
        CatalogItem(index: 5, name: "Angel Devil", detail: "Holier than thou", cost: 35_000, imageName: "ANGEL-DEVIL"),
    ]

    /// `EquipSpecialScene.m` stored a special powerup as `index + 100` in the
    /// single shared `User.powerup` slot, so only one upgrade — normal *or*
    /// special — can be equipped at a time.
    static let specialPowerupOffset = 100

    /// The soul packs `ShopScene.m` sold through StoreKit. In-app purchase is
    /// out of scope for the rewrite, so these are listed but not purchasable.
    static let soulPacks: [CatalogItem] = [
        CatalogItem(index: 0, name: "Handful o' Souls", detail: "10,000 souls", cost: 10_000, imageName: nil),
        CatalogItem(index: 1, name: "Bag o' Souls", detail: "20,000 souls", cost: 20_000, imageName: nil),
        CatalogItem(index: 2, name: "Chalice o' Souls", detail: "50,000 souls", cost: 50_000, imageName: nil),
        CatalogItem(index: 3, name: "Truck-load o' Souls", detail: "100,000 souls", cost: 100_000, imageName: nil),
        CatalogItem(index: 4, name: "Treasure Chest o' Souls", detail: "200,000 souls", cost: 200_000, imageName: nil),
    ]
}

/// Presentation metadata for a world: its name, its menu backdrop and the
/// level-select backdrop, taken from `WorldSelectScene.m`/`LevelSelectScene.m`.
struct WorldTheme: Hashable, Sendable {
    let world: Int
    let name: String
    let menuBackground: String
    let levelBackground: String
    let isMonochrome: Bool

    static func theme(for world: Int) -> WorldTheme {
        switch world {
        case 1:
            return WorldTheme(world: 1, name: "Hell", menuBackground: "bg-menu-hell", levelBackground: "bg-world-1", isMonochrome: false)
        case 2:
            return WorldTheme(world: 2, name: "Underground", menuBackground: "bg-menu-underground", levelBackground: "bg-world-2", isMonochrome: false)
        case 3:
            return WorldTheme(world: 3, name: "Ocean", menuBackground: "bg-menu-ocean", levelBackground: "bg-world-3", isMonochrome: false)
        case 4:
            return WorldTheme(world: 4, name: "Earth", menuBackground: "bg-menu-land", levelBackground: "bg-world-4", isMonochrome: false)
        case GameConstants.bonusWorld:
            return WorldTheme(world: GameConstants.bonusWorld, name: "Bonus", menuBackground: "bg-menu-hell", levelBackground: "bg-world-1", isMonochrome: false)
        case GameConstants.detectiveWorld:
            return WorldTheme(world: GameConstants.detectiveWorld, name: "Detective Devil", menuBackground: "bg-menu-detective", levelBackground: "bg-world-20", isMonochrome: true)
        default:
            return WorldTheme(world: world, name: "World \(world)", menuBackground: "bg-coming-soon", levelBackground: "bg-world-1", isMonochrome: false)
        }
    }
}

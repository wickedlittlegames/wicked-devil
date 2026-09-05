import SwiftUI
import WickedDevilCore

/// The store hub — `EquipMenuScene.m`.
struct StoreHubView: View {
    @Environment(MenuModel.self) private var model

    let onOpen: (MenuRoute) -> Void
    let onBack: () -> Void

    var body: some View {
        MenuScreen(
            title: "Store",
            backgroundImage: "bg-store-home-iphone5",
            souls: model.souls,
            onBack: onBack
        ) {
            VStack(spacing: 14) {
                Spacer(minLength: 0)

                hubButton(
                    "Devil Upgrades",
                    subtitle: model.equippedUpgradeName.map { "Equipped: \($0)" } ?? "Nothing equipped",
                    route: .powerupShop
                )
                hubButton(
                    "Special Upgrades",
                    subtitle: "\(model.ownedSpecialPowerups.count)/\(MenuCatalog.specialPowerups.count) owned",
                    route: .specialShop
                )
                hubButton(
                    "Characters",
                    subtitle: model.equippedCharacterName.map { "Playing as \($0)" } ?? "Playing as the Devil",
                    route: .characterShop
                )
                hubButton(
                    "Buy Souls",
                    subtitle: "Soul packs",
                    route: .soulShop
                )

                Spacer(minLength: 0)

                Text("Only one upgrade — devil or special — can be equipped at a time.")
                    .font(.devilCaption(13))
                    .foregroundStyle(MenuColor.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
        }
    }

    private func hubButton(_ title: String, subtitle: String, route: MenuRoute) -> some View {
        Button {
            onOpen(route)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text(subtitle)
                        .font(.devilCaption(13))
                        .foregroundStyle(MenuColor.mutedText)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold))
            }
        }
        .devilButton(.secondary)
    }
}

/// Devil and special upgrade shops — `EquipScene.m` and `EquipSpecialScene.m`.
///
/// The two originals were near-identical copies differing only in which
/// `User` array they wrote to and the `+100` offset special upgrades used in
/// the shared equipped-powerup slot, so they share one view here.
struct UpgradeShopView: View {
    enum Kind {
        case devil
        case special

        var title: String {
            switch self {
            case .devil: return "Devil Upgrades"
            case .special: return "Special Upgrades"
            }
        }

        var items: [CatalogItem] {
            switch self {
            case .devil: return MenuCatalog.powerups
            case .special: return MenuCatalog.specialPowerups
            }
        }
    }

    @Environment(MenuModel.self) private var model

    let kind: Kind
    let onBack: () -> Void

    @State private var notEnoughSouls: Int?

    var body: some View {
        MenuScreen(
            title: kind.title,
            backgroundImage: "bg-store-iphone5",
            souls: model.souls,
            onBack: onBack
        ) {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(kind.items) { item in
                        ShopRow(
                            item: item,
                            state: state(for: item),
                            canAfford: model.canAfford(item.cost),
                            action: { act(on: item) }
                        )
                    }

                    if model.hasEquippedPowerup {
                        Button("Unequip all") { model.unequipPowerups() }
                            .devilButton(.quiet)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
        }
        .alert(
            "Not Enough Souls!",
            isPresented: Binding(get: { notEnoughSouls != nil }, set: { if !$0 { notEnoughSouls = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You need \((notEnoughSouls ?? 0).formatted(.number)) more souls.")
        }
    }

    private func state(for item: CatalogItem) -> ShopRow.State {
        switch kind {
        case .devil:
            if model.isPowerupEquipped(item) { return .equipped }
            return model.ownedPowerups.contains(item.index) ? .owned : .forSale
        case .special:
            if model.isSpecialPowerupEquipped(item) { return .equipped }
            return model.ownedSpecialPowerups.contains(item.index) ? .owned : .forSale
        }
    }

    private func act(on item: CatalogItem) {
        switch state(for: item) {
        case .equipped:
            model.unequipPowerups()
        case .owned:
            switch kind {
            case .devil: model.equipPowerup(item)
            case .special: model.equipSpecialPowerup(item)
            }
        case .forSale:
            let outcome = kind == .devil ? model.buyPowerup(item) : model.buySpecialPowerup(item)
            if case .notEnoughSouls(let shortfall) = outcome { notEnoughSouls = shortfall }
        }
    }
}

/// Character skins — `CharacterShopScene.m`.
struct CharacterShopView: View {
    @Environment(MenuModel.self) private var model

    let onBack: () -> Void

    @State private var notEnoughSouls: Int?

    var body: some View {
        MenuScreen(
            title: "Characters",
            backgroundImage: "bg-store-iphone5",
            souls: model.souls,
            onBack: onBack
        ) {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(MenuCatalog.characters) { item in
                        ShopRow(
                            item: item,
                            state: state(for: item),
                            canAfford: model.canAfford(item.cost),
                            action: { act(on: item) }
                        )
                    }

                    if model.hasEquippedCharacter {
                        Button("Play as the Devil") { model.unequipCharacter() }
                            .devilButton(.quiet)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
        }
        .alert(
            "Not Enough Souls!",
            isPresented: Binding(get: { notEnoughSouls != nil }, set: { if !$0 { notEnoughSouls = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You need \((notEnoughSouls ?? 0).formatted(.number)) more souls.")
        }
    }

    private func state(for item: CatalogItem) -> ShopRow.State {
        if model.isCharacterEquipped(item) { return .equipped }
        return model.ownedCharacters.contains(item.index) ? .owned : .forSale
    }

    private func act(on item: CatalogItem) {
        switch state(for: item) {
        case .equipped: model.unequipCharacter()
        case .owned: model.equipCharacter(item)
        case .forSale:
            if case .notEnoughSouls(let shortfall) = model.buyCharacter(item) {
                notEnoughSouls = shortfall
            }
        }
    }
}

/// Soul packs — `ShopScene.m`.
///
/// The original sold these through StoreKit. In-app purchase is out of scope
/// for the rewrite (as with Parse, Facebook and Flurry), so the packs are shown
/// for completeness but cannot be bought: souls are earned by playing.
struct SoulShopView: View {
    @Environment(MenuModel.self) private var model

    let onBack: () -> Void

    var body: some View {
        MenuScreen(
            title: "Buy Souls",
            backgroundImage: "bg-store-iphone5",
            souls: model.souls,
            onBack: onBack
        ) {
            ScrollView {
                VStack(spacing: 12) {
                    MenuPanel {
                        Text("In-app purchases are not part of this rewrite. Souls are earned by finishing levels.")
                            .font(.devilBody(15))
                            .foregroundStyle(MenuColor.mutedText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

                    ForEach(MenuCatalog.soulPacks) { pack in
                        ShopRow(item: pack, state: .forSale, canAfford: false, isAvailable: false, action: {})
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
        }
    }
}

/// One purchasable/equippable row, shared by all four shop screens.
struct ShopRow: View {
    enum State { case forSale, owned, equipped }

    let item: CatalogItem
    let state: State
    let canAfford: Bool
    var isAvailable = true
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let imageName = item.imageName, UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.devilBody(18))
                Text(item.detail)
                    .font(.devilCaption(13))
                    .foregroundStyle(MenuColor.mutedText)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Button(action: action) {
                VStack(spacing: 2) {
                    Text(buttonTitle).font(.devilCaption(15))
                    if state == .forSale, isAvailable {
                        Text(item.cost.formatted(.number))
                            .font(.devilCaption(13))
                            .monospacedDigit()
                    }
                }
                .frame(minWidth: 84)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(buttonBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(isEnabled ? MenuColor.text : MenuColor.mutedText)
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
        }
        .padding(12)
        .background(MenuColor.panel, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    state == .equipped ? MenuColor.soul.opacity(0.8) : MenuColor.panelStroke.opacity(0.5),
                    lineWidth: state == .equipped ? 2 : 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name). \(item.detail). \(buttonTitle)")
    }

    private var isEnabled: Bool {
        guard isAvailable else { return false }
        switch state {
        case .forSale: return canAfford
        case .owned, .equipped: return true
        }
    }

    private var buttonTitle: String {
        guard isAvailable else { return "Unavailable" }
        switch state {
        case .equipped: return "Equipped"
        case .owned: return "Equip"
        case .forSale: return canAfford ? "Buy" : "Locked"
        }
    }

    private var buttonBackground: Color {
        switch state {
        case .equipped: return MenuColor.soul.opacity(0.28)
        case .owned: return MenuColor.ember.opacity(0.35)
        case .forSale: return Color.white.opacity(isEnabled ? 0.14 : 0.05)
        }
    }
}

#Preview("Store hub") {
    NavigationStack {
        StoreHubView(onOpen: { _ in }, onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Devil upgrades") {
    NavigationStack {
        UpgradeShopView(kind: .devil, onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Special upgrades") {
    NavigationStack {
        UpgradeShopView(kind: .special, onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Characters") {
    NavigationStack {
        CharacterShopView(onBack: {})
            .environment(MenuPreview.inProgressModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Soul packs") {
    NavigationStack {
        SoulShopView(onBack: {})
            .environment(MenuPreview.freshModel())
    }
    .preferredColorScheme(.dark)
}

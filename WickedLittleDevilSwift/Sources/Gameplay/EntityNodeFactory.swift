import SpriteKit
import WickedDevilCore

/// The authored look of a level object: everything the converter recorded that
/// affects rendering but not simulation.
struct SpriteAppearance {
    var frame: String?
    var sheet: String?
    var size: SizeF
    var rotationDegrees: Double
    var opacity: Double
    var tint: Level.Tint?

    init(
        frame: String?,
        sheet: String?,
        size: SizeF,
        rotationDegrees: Double?,
        opacity: Int?,
        tint: Level.Tint?
    ) {
        self.frame = frame
        self.sheet = sheet
        self.size = size
        self.rotationDegrees = rotationDegrees ?? 0
        self.opacity = Double(opacity ?? 255) / 255.0
        self.tint = tint
    }

    init(_ data: Level.PlatformData) {
        self.init(
            frame: data.spriteFrame, sheet: data.spriteSheet, size: data.size,
            rotationDegrees: data.rotationDegrees, opacity: data.opacity, tint: data.tint
        )
    }

    init(_ data: Level.CollectableData) {
        self.init(
            frame: data.spriteFrame, sheet: data.spriteSheet, size: data.size,
            rotationDegrees: data.rotationDegrees, opacity: data.opacity, tint: data.tint
        )
    }

    init(_ data: Level.EnemyData) {
        self.init(
            frame: data.spriteFrame, sheet: data.spriteSheet, size: data.size,
            rotationDegrees: data.rotationDegrees, opacity: data.opacity, tint: data.tint
        )
    }
}

/// Turns authored level objects into sprites.
///
/// Every object in the converted JSON carries the sprite frame and sheet the
/// original used, so nodes are built straight from that rather than from a
/// hand-written kind-to-image table.
enum EntityNodeFactory {

    static func platformNode(appearance: SpriteAppearance?, fallbackSize: SizeF) -> SKSpriteNode {
        let node = sprite(appearance, fallbackSize: fallbackSize)
        node.zPosition = ZOrder.platform
        return node
    }

    static func collectableNode(
        appearance: SpriteAppearance?,
        kind: CollectableKind,
        fallbackSize: SizeF
    ) -> SKSpriteNode {
        let node = sprite(appearance, fallbackSize: fallbackSize)
        node.zPosition = ZOrder.collectable
        // `HaloCollectable.m` span its sprite continuously.
        if kind == .halo {
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 3)))
        }
        return node
    }

    static func enemyNode(
        appearance: SpriteAppearance?,
        kind: EnemyKind,
        fallbackSize: SizeF
    ) -> SKSpriteNode {
        let node = sprite(appearance, fallbackSize: fallbackSize)
        node.zPosition = ZOrder.enemy

        // `Enemy.m` flapped the bat forever off the `BatAnim` sheet.
        if kind == .bat, let atlas = SpriteAtlas.named("BatAnim") {
            let frames = atlas.animationFrames(prefix: "bat-flap", count: 7)
            if !frames.isEmpty {
                node.run(SKAction.repeatForever(
                    SKAction.animate(
                        with: frames.map(\.texture),
                        timePerFrame: 0.5,
                        resize: false,
                        restore: false
                    )
                ))
            }
        }
        return node
    }

    static func projectileNode(size: SizeF) -> SKSpriteNode {
        let node = sprite(
            SpriteAppearance(
                frame: "ingame-rocket", sheet: "IngameSprites", size: size,
                rotationDegrees: 0, opacity: 255, tint: nil
            ),
            fallbackSize: size
        )
        node.zPosition = ZOrder.projectile
        return node
    }

    // MARK: - Helpers

    private static func sprite(_ appearance: SpriteAppearance?, fallbackSize: SizeF) -> SKSpriteNode {
        let requested = appearance?.size ?? fallbackSize
        let target = CGSize(width: requested.width, height: requested.height)

        let node: SKSpriteNode
        if let frameName = appearance?.frame,
           let resolved = SpriteLibrary.frame(named: frameName, sheet: appearance?.sheet) {
            node = SKSpriteNode(texture: resolved.texture)
            node.size = target.width > 0 && target.height > 0 ? target : resolved.size
        } else {
            // A magenta block makes a missing frame obvious rather than invisible.
            node = SKSpriteNode(color: .magenta, size: target)
        }

        guard let appearance else { return node }
        // Cocos2d rotation is clockwise-positive; SpriteKit's is anticlockwise.
        node.zRotation = -appearance.rotationDegrees * .pi / 180
        node.alpha = appearance.opacity
        if let tint = appearance.tint, tint.r != 255 || tint.g != 255 || tint.b != 255 {
            node.color = SKColor(
                red: CGFloat(tint.r) / 255,
                green: CGFloat(tint.g) / 255,
                blue: CGFloat(tint.b) / 255,
                alpha: 1
            )
            node.colorBlendFactor = 1
        }
        return node
    }
}

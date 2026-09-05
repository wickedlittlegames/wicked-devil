import SpriteKit
import UIKit

/// Builds `SKEmitterNode`s from the cocos2d / Particle Designer `.plist` files
/// the original `FXLayer` loaded.
///
/// SpriteKit cannot read those plists directly, so the fields are mapped here.
/// cocos2d expresses colour variance and lifespan variance as a plus/minus
/// amount, whereas SpriteKit's `*Range` properties describe the *full* range,
/// hence the doubling.
enum ParticleFactory {

    private static var cache: [String: SKEmitterNode] = [:]

    /// Returns a fresh copy of the named effect, ready to be positioned and
    /// added to the scene.
    static func emitter(named name: String) -> SKEmitterNode? {
        if let template = cache[name] { return template.copy() as? SKEmitterNode }
        guard let built = build(name: name) else { return nil }
        cache[name] = built
        return built.copy() as? SKEmitterNode
    }

    private static func build(name: String) -> SKEmitterNode? {
        guard let plist = AssetLocator.plist(named: name) else { return nil }

        func number(_ key: String) -> CGFloat {
            CGFloat((plist[key] as? NSNumber)?.doubleValue ?? 0)
        }

        let emitter = SKEmitterNode()

        if let textureFile = plist["textureFileName"] as? String,
           let frame = SpriteLibrary.image(named: textureFile) {
            emitter.particleTexture = frame.texture
        }

        let lifespan = number("particleLifespan")
        let lifespanVariance = number("particleLifespanVariance")
        emitter.particleLifetime = lifespan
        emitter.particleLifetimeRange = lifespanVariance * 2

        let maxParticles = max(number("maxParticles"), 1)
        let duration = number("duration")
        emitter.numParticlesToEmit = Int(maxParticles)
        // cocos2d derived the emission rate from the particle lifetime, which is
        // zero in these files, meaning "emit everything at once". A one-frame
        // burst reproduces that.
        let burstWindow = max(duration, 1.0 / 60.0)
        emitter.particleBirthRate = maxParticles / burstWindow

        emitter.particlePosition = .zero
        emitter.particlePositionRange = CGVector(
            dx: number("sourcePositionVariancex") * 2,
            dy: number("sourcePositionVariancey") * 2
        )

        emitter.emissionAngle = number("angle") * .pi / 180
        emitter.emissionAngleRange = number("angleVariance") * 2 * .pi / 180
        emitter.particleSpeed = number("speed")
        emitter.particleSpeedRange = number("speedVariance") * 2
        emitter.xAcceleration = number("gravityx")
        emitter.yAcceleration = number("gravityy")

        emitter.particleSize = CGSize(width: number("startParticleSize"), height: number("startParticleSize"))
        emitter.particleScale = 1
        emitter.particleScaleRange = number("startParticleSizeVariance") * 2 / max(number("startParticleSize"), 1)
        let finishSize = number("finishParticleSize")
        let startSize = max(number("startParticleSize"), 1)
        if lifespanEstimate(lifespan, lifespanVariance) > 0 {
            emitter.particleScaleSpeed = (finishSize / startSize - 1) / lifespanEstimate(lifespan, lifespanVariance)
        }

        emitter.particleRotation = number("rotationStart") * .pi / 180
        emitter.particleRotationRange = number("rotationStartVariance") * 2 * .pi / 180

        emitter.particleColor = UIColor(
            red: number("startColorRed"),
            green: number("startColorGreen"),
            blue: number("startColorBlue"),
            alpha: 1
        )
        emitter.particleColorBlendFactor = 1
        emitter.particleColorRedRange = number("startColorVarianceRed") * 2
        emitter.particleColorGreenRange = number("startColorVarianceGreen") * 2
        emitter.particleColorBlueRange = number("startColorVarianceBlue") * 2

        emitter.particleAlpha = number("startColorAlpha")
        emitter.particleAlphaRange = number("startColorVarianceAlpha") * 2
        if lifespanEstimate(lifespan, lifespanVariance) > 0 {
            emitter.particleAlphaSpeed =
                (number("finishColorAlpha") - number("startColorAlpha"))
                / lifespanEstimate(lifespan, lifespanVariance)
        }

        // cocos2d blend constants: GL_ONE (1) as the destination is additive.
        if (plist["blendFuncDestination"] as? NSNumber)?.intValue == 1 {
            emitter.particleBlendMode = .add
        }

        return emitter
    }

    /// The average life a particle ends up with, used to convert cocos2d's
    /// start/finish values into SpriteKit's per-second rates.
    private static func lifespanEstimate(_ lifespan: CGFloat, _ variance: CGFloat) -> CGFloat {
        max(lifespan, variance / 2)
    }
}

/// The three effects `FXLayer` preloaded, by their original plist names.
enum ParticleEffect {
    static let mineExplosion = "AnimExplosion"
    static let bigCollectable = "CollectedBig"
    static let halo = "haloCollect"
}

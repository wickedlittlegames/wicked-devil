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
        // cocos2d set its emission rate to `totalParticles / particleLifespan`
        // and emitted while `emitCounter > 1/rate`. A lifespan of zero makes
        // that interval zero, so the whole system fires on the first frame
        // regardless of `duration` — `duration` only bounds how long the
        // emitter stays alive, and every burst effect here has a lifespan of
        // zero. A one-frame window reproduces that.
        let burstWindow = lifespan > 0 ? max(duration, 1.0 / 60.0) : 1.0 / 60.0
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

        applyBlendMode(to: emitter, plist: plist, number: number)

        return emitter
    }

    /// cocos2d GL blend constants: 1 is `GL_ONE`, 770 `GL_SRC_ALPHA`, 771
    /// `GL_ONE_MINUS_SRC_ALPHA`.
    private enum GLBlend {
        static let one = 1
        static let oneMinusSrcAlpha = 771
    }

    /// Translates the plist's raw OpenGL blend factors.
    ///
    /// The interesting case is `CollectedBig.plist`, which authors *both*
    /// factors as `GL_ONE_MINUS_SRC_ALPHA` together with `startColorAlpha 0`.
    /// Read naively that is an invisible effect, and it is what we shipped: the
    /// soul-jar burst did not render at all.
    ///
    /// It was not invisible in cocos2d. `CCParticleSystem.m:114` takes the
    /// blend factors straight from the plist, and `setTexture:` only overrides
    /// them when they still hold the defaults (`CCParticleSystem.m:624-634`),
    /// which 771/771 does not. `CCParticleSystemQuad.m:339` then writes the
    /// particle's alpha into the vertex colour without folding it into RGB. So
    /// the hardware computed `src * (1 - 0) + dst * (1 - 0)` — both factors
    /// resolve to one, which is *fully additive at full intensity*. Particle
    /// Designer's preview would have shown exactly that, which is presumably
    /// why the author left it.
    ///
    /// So: an inverted blend is additive, and the authored alpha is really the
    /// inverse of the particle's coverage. `finishColorAlpha 0` with a variance
    /// of 0.5 gives each particle an end alpha in -0.5...0.5; the negative half
    /// clamped back to zero on the float-to-GLubyte conversion, so the burst
    /// held roughly full brightness for its (very short, mean 0.16s) life and
    /// popped out rather than fading. That is reproduced with a flat alpha and
    /// no fade.
    private static func applyBlendMode(
        to emitter: SKEmitterNode,
        plist: [String: Any],
        number: (String) -> CGFloat
    ) {
        let source = (plist["blendFuncSource"] as? NSNumber)?.intValue ?? 0
        let destination = (plist["blendFuncDestination"] as? NSNumber)?.intValue ?? 0

        if destination == GLBlend.one {
            emitter.particleBlendMode = .add
            return
        }

        guard source == GLBlend.oneMinusSrcAlpha, destination == GLBlend.oneMinusSrcAlpha
        else { return }

        emitter.particleBlendMode = .add
        emitter.particleAlpha = 1 - number("startColorAlpha")
        emitter.particleAlphaRange = 0
        emitter.particleAlphaSpeed = 0
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

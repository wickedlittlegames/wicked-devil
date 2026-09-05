import CoreText
import Foundation
import UIKit

/// Registers the original `CrashLandingBB.ttf` at runtime.
///
/// Registering in code rather than through `UIAppFonts` keeps the generated
/// Info.plist untouched and works regardless of whether the font ships at the
/// bundle root or inside the `Fonts` folder reference.
enum GameFont {
    /// The font's PostScript name, as used by `UILayer.m`'s `CCLabelTTF`s.
    static let name = "CrashLandingBB"
    /// Used when the custom font could not be registered.
    static let fallbackName = "AvenirNextCondensed-Bold"

    private static var registered = false

    @discardableResult
    static func register() -> Bool {
        if registered { return true }
        guard let url = AssetLocator.url(forResource: "CrashLandingBB", withExtension: "ttf") else {
            return false
        }
        var error: Unmanaged<CFError>?
        registered = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        return registered
    }

    /// The best available font name, registering the bundled font on first use.
    static var preferredName: String {
        register()
        return UIFont(name: name, size: 12) != nil ? name : fallbackName
    }
}

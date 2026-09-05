import CoreGraphics
import Foundation

/// How the 320x480 point space every level was authored in maps onto a modern
/// screen.
///
/// The original shipped for exactly two viewports, 320x480 and 320x568, and
/// handled the taller one by scaling its vertical physics constants by
/// 568/480 (`Player.m`, `Platform.m`, `Enemy.m`). That trick does not survive
/// contact with a 19.5:9 phone: the same rule would raise the jump by 45% over
/// level geometry that never moved, turning authored gaps into non-events and
/// swinging moving platforms 145pt into their neighbours.
///
/// So the play field is treated as fixed instead. The scene is scaled so the
/// whole 320x480 design box is always on screen at authored size, and whatever
/// the device has left over becomes scenery:
///
/// - **Taller than 3:2** (every modern iPhone) — surplus height, which
///   `GameWorld.cameraY` spends entirely on look-ahead above the player.
/// - **Wider than 3:2** (iPad in portrait) — surplus width either side of the
///   320pt play column, filled by the background.
///
/// The player's horizontal range, every jump arc and every platform gap
/// therefore stay exactly as designed on all hardware.
enum GameplayLayout {

    /// The point width every level was authored against.
    static let designWidth: CGFloat = 320
    /// The point height the original device had.
    static let designHeight: CGFloat = 480

    static let designSize = CGSize(width: designWidth, height: designHeight)

    /// The scene size to use for a view of `viewSize`, in authored points.
    ///
    /// Always at least `designSize`, and always the same aspect ratio as the
    /// view so nothing is cropped or letterboxed.
    static func sceneSize(forViewSize viewSize: CGSize) -> CGSize {
        guard viewSize.width > 0, viewSize.height > 0 else { return designSize }
        let scale = min(viewSize.width / designWidth, viewSize.height / designHeight)
        guard scale > 0, scale.isFinite else { return designSize }
        return CGSize(width: viewSize.width / scale, height: viewSize.height / scale)
    }

    /// How many authored points one view point is worth, for converting UIKit
    /// safe-area insets into scene units.
    static func scenePointsPerViewPoint(sceneSize: CGSize, viewSize: CGSize) -> CGFloat {
        guard viewSize.width > 0 else { return 1 }
        return sceneSize.width / viewSize.width
    }
}

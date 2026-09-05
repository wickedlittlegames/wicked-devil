import CoreGraphics

/// Safe-area insets converted from view points into authored scene points.
struct SafeAreaInsets: Equatable {
    var top: CGFloat = 0
    var bottom: CGFloat = 0

    static let zero = SafeAreaInsets()
}

import Foundation

/// A collection of resolved visual properties for a component.
///
/// Each property holds a **token name** (e.g. `"color.text.primary"`)
/// that the renderer resolves via `AuraColorResolver` and friends.
///
/// Components use `ComponentStyle` to know **how they look** for a given theme.
public struct ComponentStyle: Decodable, Sendable {
    public var textColor: String?
    public var backgroundColor: String?
    public var borderColor: String?
    public var font: String?
    public var padding: String?
    public var margin: String?
    public var cornerRadius: Double?

    public init(
        textColor: String? = nil,
        backgroundColor: String? = nil,
        borderColor: String? = nil,
        font: String? = nil,
        padding: String? = nil,
        margin: String? = nil,
        cornerRadius: Double? = nil
    ) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.font = font
        self.padding = padding
        self.margin = margin
        self.cornerRadius = cornerRadius
    }

    public static let empty = ComponentStyle()
}

import Foundation

/// A value-type theme that maps component types + theme names to visual styles.
///
/// Create a default theme, decode from the server, or merge both:
/// ```swift
/// let theme = AuraTheme.default
/// let serverTheme = try decoder.decode(AuraTheme.self, from: json)
/// ```
///
/// No singletons. The theme is created and injected where needed.
public struct AuraTheme: Decodable, Sendable {

    // MARK: - Component Styles

    public var heading: [AuraComponentTheme: ComponentStyle] = [:]
    public var text: [AuraComponentTheme: ComponentStyle] = [:]
    public var button: [AuraComponentTheme: ComponentStyle] = [:]
    public var container: [AuraComponentTheme: ComponentStyle] = [:]
    public var image: [AuraComponentTheme: ComponentStyle] = [:]

    // MARK: - Init

    public init(
        heading: [AuraComponentTheme: ComponentStyle] = [:],
        text: [AuraComponentTheme: ComponentStyle] = [:],
        button: [AuraComponentTheme: ComponentStyle] = [:],
        container: [AuraComponentTheme: ComponentStyle] = [:],
        image: [AuraComponentTheme: ComponentStyle] = [:]
    ) {
        self.heading = heading
        self.text = text
        self.button = button
        self.container = container
        self.image = image
    }

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case heading, text, button, container, image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.heading = try container.decodeIfPresent([String: ComponentStyle].self, forKey: .heading)?
            .compactMapKeys { AuraComponentTheme(rawValue: $0) } ?? [:]
        self.text = try container.decodeIfPresent([String: ComponentStyle].self, forKey: .text)?
            .compactMapKeys { AuraComponentTheme(rawValue: $0) } ?? [:]
        self.button = try container.decodeIfPresent([String: ComponentStyle].self, forKey: .button)?
            .compactMapKeys { AuraComponentTheme(rawValue: $0) } ?? [:]
        self.container = try container.decodeIfPresent([String: ComponentStyle].self, forKey: .container)?
            .compactMapKeys { AuraComponentTheme(rawValue: $0) } ?? [:]
        self.image = try container.decodeIfPresent([String: ComponentStyle].self, forKey: .image)?
            .compactMapKeys { AuraComponentTheme(rawValue: $0) } ?? [:]
    }

    // MARK: - Default Theme

    /// The built-in default theme. Covers all standard component + theme combinations.
    public static let `default` = AuraTheme(
        heading: [
            .primary: ComponentStyle(textColor: "color.text.primary", font: "font.heading1", margin: "spacing.md"),
            .secondary: ComponentStyle(textColor: "color.text.secondary", font: "font.heading2", margin: "spacing.sm"),
            .tertiary: ComponentStyle(textColor: "color.text.tertiary", font: "font.heading3", margin: "spacing.sm"),
            .danger: ComponentStyle(textColor: "color.text.danger", font: "font.heading1", margin: "spacing.md"),
            .success: ComponentStyle(textColor: "color.text.success", font: "font.heading1", margin: "spacing.md"),
        ],
        text: [
            .primary: ComponentStyle(textColor: "color.text.primary", font: "font.body"),
            .secondary: ComponentStyle(textColor: "color.text.secondary", font: "font.bodySmall"),
            .danger: ComponentStyle(textColor: "color.text.danger", font: "font.body"),
            .success: ComponentStyle(textColor: "color.text.success", font: "font.body"),
            .info: ComponentStyle(textColor: "color.text.info", font: "font.body"),
        ],
        button: [
            .primary: ComponentStyle(
                textColor: "color.text.onPrimary",
                backgroundColor: "color.control.primary",
                font: "font.button",
                padding: "spacing.md",
                cornerRadius: 8
            ),
            .secondary: ComponentStyle(
                textColor: "color.text.primary",
                backgroundColor: "color.control.secondary",
                font: "font.button",
                padding: "spacing.md",
                cornerRadius: 8
            ),
            .danger: ComponentStyle(
                textColor: "color.text.onPrimary",
                backgroundColor: "color.control.danger",
                font: "font.button",
                padding: "spacing.md",
                cornerRadius: 8
            ),
            .ghost: ComponentStyle(
                textColor: "color.text.primary",
                backgroundColor: "color.control.ghost",
                font: "font.button",
                padding: "spacing.md"
            ),
        ],
        container: [
            .primary: ComponentStyle(
                backgroundColor: "color.surface.primary",
                padding: "spacing.md",
                cornerRadius: 12
            ),
            .secondary: ComponentStyle(
                backgroundColor: "color.surface.secondary",
                padding: "spacing.md",
                cornerRadius: 8
            ),
        ],
        image: [
            .primary: ComponentStyle(cornerRadius: 8),
        ]
    )
}

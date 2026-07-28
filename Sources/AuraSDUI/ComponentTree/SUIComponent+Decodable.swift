import Foundation
import AuraDS

/// Decodes a JSON payload into the `SUIComponent` tree.
///
/// The decoder reads the `"type"` field to determine which case to create,
/// then maps the raw `AuraComponent` into the appropriate typed SDUI component.
extension SUIComponent: Decodable {

    enum CodingKeys: String, CodingKey {
        case type
        case content
        case theme
        case action
        case children
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(AuraComponentType.self, forKey: .type)

        switch type {
        case .heading:
            let content = try container.decode(String.self, forKey: .content)
            let theme: AuraComponentTheme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            self = .heading(AuraSDUIHeading(content: content, theme: theme))

        case .text:
            let content = try container.decode(String.self, forKey: .content)
            let theme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            self = .text(AuraSDUIText(content: content, theme: theme))

        case .button:
            let content = try container.decode(String.self, forKey: .content)
            let theme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            let action = try container.decode(AuraComponentAction.self, forKey: .action)
            self = .button(AuraSDUIButton(label: content, theme: theme, action: action))

        case .container:
            let theme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            let children = try container.decodeIfPresent([SUIComponent].self, forKey: .children) ?? []
            self = .container(theme: theme, children: children)

        case .spacer:
            self = .spacer

        case .image:
            // Image support will be added in a future iteration
            let raw = try AuraComponent(from: decoder)
            self = .unknown(raw)
        }
    }
}

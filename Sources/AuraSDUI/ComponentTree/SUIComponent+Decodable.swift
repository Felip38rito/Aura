import Foundation
import AuraDS

/// Decodes a JSON payload into the `SUIComponent` tree.
///
/// The decoder reads the `"type"` field to determine which case to create,
/// then maps the raw `AuraComponent` into the appropriate typed SDUI component.
///
/// The `"id"` field is **required** — it provides the stable identity the
/// renderer relies on. A missing `id` throws a `DecodingError`.
extension SUIComponent: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case theme
        case action
        case children
        case altText
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let type = try container.decode(AuraComponentType.self, forKey: .type)

        switch type {
        case .heading:
            let content = try container.decode(String.self, forKey: .content)
            let theme: AuraComponentTheme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            self = .heading(id: id, AuraSDUIHeading(content: content, theme: theme))

        case .text:
            let content = try container.decode(String.self, forKey: .content)
            let theme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            self = .text(id: id, AuraSDUIText(content: content, theme: theme))

        case .button:
            let content = try container.decode(String.self, forKey: .content)
            let theme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            let action = try container.decode(AuraComponentAction.self, forKey: .action)
            self = .button(id: id, AuraSDUIButton(label: content, theme: theme, action: action))

        case .container:
            let theme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            let children = try container.decodeIfPresent([SUIComponent].self, forKey: .children) ?? []
            self = .container(id: id, theme: theme, children: children)

        case .spacer:
            self = .spacer(id: id)

        case .image:
            let source = try container.decode(String.self, forKey: .content)
            let theme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme) ?? .primary
            let altText = try container.decodeIfPresent(String.self, forKey: .altText)
            self = .image(id: id, AuraSDUIImage(source: source, theme: theme, altText: altText))

        case .unknown:
            let raw = try AuraComponent(from: decoder)
            self = .unknown(id: id, raw)
        }
    }
}

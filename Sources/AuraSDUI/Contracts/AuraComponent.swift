import Foundation
import AuraDS

/// A raw component as decoded from the server JSON payload.
///
/// This is the **entry point** of the SDUI pipeline:
/// ```json
/// { "type": "button", "content": "Salvar", "theme": "primary", "action": { ... } }
/// ```
///
/// After decoding, `AuraComponent` is mapped into a typed SDUI component
/// (e.g. `AuraSDUIButton`) which the renderer consumes.
public struct AuraComponent: Decodable, Sendable {
    public let type: AuraComponentType
    public let content: AuraComponentContent?
    public let theme: AuraComponentTheme?
    public let action: AuraComponentAction?
    public let children: [AuraComponent]?

    enum CodingKeys: String, CodingKey {
        case type
        case content
        case theme
        case action
        case children
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(AuraComponentType.self, forKey: .type)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.theme = try container.decodeIfPresent(AuraComponentTheme.self, forKey: .theme)
        self.action = try container.decodeIfPresent(AuraComponentAction.self, forKey: .action)
        self.children = try container.decodeIfPresent([AuraComponent].self, forKey: .children)
    }
}

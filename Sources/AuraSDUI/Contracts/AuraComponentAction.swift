import Foundation

/// An action that a component can trigger.
///
/// Decoded from JSON:
/// ```json
/// { "type": "deepLink", "value": "aura://profile/123" }
/// ```
public enum AuraComponentAction: Decodable, Sendable {
    case deepLink(URL)
    case navigate(String)
    case openURL(URL)
    case custom(String)

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let value = try container.decode(String.self, forKey: .value)

        switch type {
        case "deepLink":
            guard let url = URL(string: value) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .value,
                    in: container,
                    debugDescription: "Invalid deepLink URL: \(value)"
                )
            }
            self = .deepLink(url)
        case "navigate":
            self = .navigate(value)
        case "openURL":
            guard let url = URL(string: value) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .value,
                    in: container,
                    debugDescription: "Invalid openURL: \(value)"
                )
            }
            self = .openURL(url)
        case "custom":
            self = .custom(value)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown action type: \(type)"
            )
        }
    }
}

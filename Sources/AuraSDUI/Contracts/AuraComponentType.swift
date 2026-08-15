import Foundation

/// The semantic type of a component.
///
/// Maps 1:1 to the `"type"` field in the JSON payload.
///
/// Unknown types decode to `.unknown` instead of throwing, so a server that
/// ships a new component type doesn't break decoding of the whole screen.
public enum AuraComponentType: String, Decodable, CaseIterable, Sendable {
    case heading
    case text
    case button
    case container
    case image
    case spacer
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = AuraComponentType(rawValue: raw) ?? .unknown
    }
}

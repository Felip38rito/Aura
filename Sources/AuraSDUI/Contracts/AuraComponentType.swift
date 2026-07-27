import Foundation

/// The semantic type of a component.
///
/// Maps 1:1 to the `"type"` field in the JSON payload.
public enum AuraComponentType: String, Decodable, CaseIterable, Sendable {
    case heading
    case text
    case button
    case container
    case image
    case spacer
}

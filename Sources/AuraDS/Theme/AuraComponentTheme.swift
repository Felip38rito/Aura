import Foundation

/// Semantic theme names that components use to declare their visual intent.
///
/// A component says `"theme": "primary"` and the `AuraTheme` resolves
/// which `ComponentStyle` applies based on the component type.
///
/// Inspired by shadcn/ui, Material Design 3, and Tailwind conventions.
public enum AuraComponentTheme: String, Decodable, CaseIterable, Sendable {
    case primary
    case secondary
    case tertiary
    case danger
    case success
    case warning
    case info
    case ghost
    case neutral
}

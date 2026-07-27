import Foundation

/// Semantic font tokens for the Aura Design System.
///
/// These describe the **typographic role**, not a specific font family or size.
/// The actual `Font` is resolved by `AuraFontResolver`.
public enum AuraFontToken: String, Decodable, CaseIterable, Sendable {
    case heading1 = "font.heading1"
    case heading2 = "font.heading2"
    case heading3 = "font.heading3"
    case body = "font.body"
    case bodySmall = "font.bodySmall"
    case caption = "font.caption"
    case button = "font.button"
    case buttonSmall = "font.buttonSmall"
    case label = "font.label"
    case largeTitle = "font.largeTitle"
}

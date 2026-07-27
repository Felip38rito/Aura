import Foundation

/// Semantic color tokens for the Aura Design System.
///
/// These describe the **role** of a color, not its visual value.
/// The actual `Color` is resolved by `AuraColorResolver`.
public enum AuraColorToken: String, Decodable, CaseIterable, Sendable {
    // ── Text ──
    case textPrimary = "color.text.primary"
    case textSecondary = "color.text.secondary"
    case textTertiary = "color.text.tertiary"
    case textDanger = "color.text.danger"
    case textSuccess = "color.text.success"
    case textWarning = "color.text.warning"
    case textInfo = "color.text.info"
    case textDisabled = "color.text.disabled"
    case textOnPrimary = "color.text.onPrimary"
    case textOnDark = "color.text.onDark"

    // ── Control / Button ──
    case controlPrimary = "color.control.primary"
    case controlPrimaryPressed = "color.control.primaryPressed"
    case controlSecondary = "color.control.secondary"
    case controlDanger = "color.control.danger"
    case controlSuccess = "color.control.success"
    case controlGhost = "color.control.ghost"

    // ── Surface / Background ──
    case surfacePrimary = "color.surface.primary"
    case surfaceSecondary = "color.surface.secondary"
    case surfaceTertiary = "color.surface.tertiary"
    case backgroundPrimary = "color.background.primary"
    case backgroundSecondary = "color.background.secondary"

    // ── Border ──
    case borderPrimary = "color.border.primary"
    case borderSecondary = "color.border.secondary"
    case borderDanger = "color.border.danger"

    // ── Neutral ──
    case neutralWhite = "color.neutral.white"
    case neutralBlack = "color.neutral.black"
    case neutralClear = "color.neutral.clear"
}

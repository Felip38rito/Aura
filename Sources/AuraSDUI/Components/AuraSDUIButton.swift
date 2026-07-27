import Foundation
import AuraDS

/// A typed SDUI button component.
///
/// Mapped from `AuraComponent` when `type == .button`.
public struct AuraSDUIButton: Sendable {
    public let label: String
    public let theme: AuraComponentTheme
    public let action: AuraComponentAction

    public init(label: String, theme: AuraComponentTheme, action: AuraComponentAction) {
        self.label = label
        self.theme = theme
        self.action = action
    }
}

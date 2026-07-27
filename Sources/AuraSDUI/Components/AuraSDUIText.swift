import Foundation
import AuraDS

/// A typed SDUI text component.
public struct AuraSDUIText: Sendable {
    public let content: String
    public let theme: AuraComponentTheme

    public init(content: String, theme: AuraComponentTheme) {
        self.content = content
        self.theme = theme
    }
}

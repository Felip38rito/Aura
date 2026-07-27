import Foundation
import AuraDS

/// A typed SDUI heading component.
public struct AuraSDUIHeading: Sendable {
    public let content: String
    public let theme: AuraComponentTheme

    public init(content: String, theme: AuraComponentTheme) {
        self.content = content
        self.theme = theme
    }
}

import Foundation
import AuraDS

public struct AuraSDUIImage: Sendable {
    public let source: String
    public let theme: AuraComponentTheme
    public let altText: String?

    public init(source: String, theme: AuraComponentTheme, altText: String? = nil) {
        self.source = source
        self.theme = theme
        self.altText = altText
    }
}

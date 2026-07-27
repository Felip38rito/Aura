import Foundation

/// Resolves `AuraSpacingToken` into a concrete `CGFloat`.
public struct AuraSpacingResolver: Sendable {
    public let resolve: @Sendable (AuraSpacingToken) -> CGFloat

    public init(resolve: @escaping @Sendable (AuraSpacingToken) -> CGFloat) {
        self.resolve = resolve
    }

    public static let `default` = AuraSpacingResolver { token in
        switch token {
        case .xs: 4
        case .sm: 8
        case .md: 16
        case .lg: 24
        case .xl: 32
        case .xxl: 48
        }
    }
}

import SwiftUI

// MARK: - Color Resolver

private struct ColorResolverKey: EnvironmentKey {
    static let defaultValue: AuraColorResolver = .default
}

extension EnvironmentValues {
    public var colorResolver: AuraColorResolver {
        get { self[ColorResolverKey.self] }
        set { self[ColorResolverKey.self] = newValue }
    }
}

// MARK: - Font Resolver

private struct FontResolverKey: EnvironmentKey {
    static let defaultValue: AuraFontResolver = .default
}

extension EnvironmentValues {
    public var fontResolver: AuraFontResolver {
        get { self[FontResolverKey.self] }
        set { self[FontResolverKey.self] = newValue }
    }
}

// MARK: - Spacing Resolver

private struct SpacingResolverKey: EnvironmentKey {
    static let defaultValue: AuraSpacingResolver = .default
}

extension EnvironmentValues {
    public var spacingResolver: AuraSpacingResolver {
        get { self[SpacingResolverKey.self] }
        set { self[SpacingResolverKey.self] = newValue }
    }
}

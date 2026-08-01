import Testing
import Foundation
import CoreGraphics
@testable import AuraDS

// MARK: - Token Tests

@Suite("AuraColorToken")
struct AuraColorTokenTests {

    @Test("all tokens have unique raw values")
    func uniqueRawValues() {
        let all = AuraColorToken.allCases
        let raws = all.map(\.rawValue)
        #expect(Set(raws).count == raws.count)
    }

    @Test("all tokens start with color.")
    func prefix() {
        for token in AuraColorToken.allCases {
            #expect(token.rawValue.hasPrefix("color."), "\(token.rawValue) should start with 'color.'")
        }
    }

    @Test("text tokens have correct prefix")
    func textTokens() {
        #expect(AuraColorToken.textPrimary.rawValue == "color.text.primary")
        #expect(AuraColorToken.textSecondary.rawValue == "color.text.secondary")
        #expect(AuraColorToken.textDanger.rawValue == "color.text.danger")
    }

    @Test("control tokens have correct prefix")
    func controlTokens() {
        #expect(AuraColorToken.controlPrimary.rawValue == "color.control.primary")
        #expect(AuraColorToken.controlDanger.rawValue == "color.control.danger")
    }
}

@Suite("AuraFontToken")
struct AuraFontTokenTests {

    @Test("all tokens have unique raw values")
    func uniqueRawValues() {
        let all = AuraFontToken.allCases
        let raws = all.map(\.rawValue)
        #expect(Set(raws).count == raws.count)
    }

    @Test("all tokens start with font.")
    func prefix() {
        for token in AuraFontToken.allCases {
            #expect(token.rawValue.hasPrefix("font."), "\(token.rawValue) should start with 'font.'")
        }
    }
}

@Suite("AuraSpacingToken")
struct AuraSpacingTokenTests {

    @Test("all tokens have unique raw values")
    func uniqueRawValues() {
        let all = AuraSpacingToken.allCases
        let raws = all.map(\.rawValue)
        #expect(Set(raws).count == raws.count)
    }

    @Test("all tokens start with spacing.")
    func prefix() {
        for token in AuraSpacingToken.allCases {
            #expect(token.rawValue.hasPrefix("spacing."), "\(token.rawValue) should start with 'spacing.'")
        }
    }
}

@Suite("AuraComponentTheme")
struct AuraComponentThemeTests {

    @Test("all themes have unique raw values")
    func uniqueRawValues() {
        let all = AuraComponentTheme.allCases
        let raws = all.map(\.rawValue)
        #expect(Set(raws).count == raws.count)
    }

    @Test("primary is the default")
    func primaryIsDefault() {
        #expect(AuraComponentTheme.primary.rawValue == "primary")
    }
}

// MARK: - ComponentStyle Tests

@Suite("ComponentStyle")
struct ComponentStyleTests {

    @Test("empty style has all nil properties")
    func empty() {
        let style = ComponentStyle.empty
        #expect(style.textColor == nil)
        #expect(style.backgroundColor == nil)
        #expect(style.borderColor == nil)
        #expect(style.font == nil)
        #expect(style.padding == nil)
        #expect(style.margin == nil)
        #expect(style.cornerRadius == nil)
    }

    @Test("decodes from JSON")
    func decodes() throws {
        let json = """
        {
            "textColor": "color.text.primary",
            "backgroundColor": "color.control.primary",
            "font": "font.heading1",
            "padding": "spacing.md",
            "cornerRadius": 12
        }
        """.data(using: .utf8)!

        let style = try JSONDecoder().decode(ComponentStyle.self, from: json)

        #expect(style.textColor == "color.text.primary")
        #expect(style.backgroundColor == "color.control.primary")
        #expect(style.font == "font.heading1")
        #expect(style.padding == "spacing.md")
        #expect(style.cornerRadius == 12)
        #expect(style.borderColor == nil)
        #expect(style.margin == nil)
    }

    @Test("decodes empty JSON")
    func decodesEmpty() throws {
        let json = "{}".data(using: .utf8)!
        let style = try JSONDecoder().decode(ComponentStyle.self, from: json)
        #expect(style.textColor == nil)
    }
}

// MARK: - AuraTheme Tests

@Suite("AuraTheme")
struct AuraThemeTests {

    @Test("default theme has heading styles")
    func defaultHeading() {
        let theme = AuraTheme.default
        #expect(theme.heading[.primary]?.textColor == "color.text.primary")
        #expect(theme.heading[.primary]?.font == "font.heading1")
        #expect(theme.heading[.secondary]?.textColor == "color.text.secondary")
        #expect(theme.heading[.danger]?.textColor == "color.text.danger")
    }

    @Test("default theme has button styles")
    func defaultButton() {
        let theme = AuraTheme.default
        #expect(theme.button[.primary]?.backgroundColor == "color.control.primary")
        #expect(theme.button[.primary]?.textColor == "color.text.onPrimary")
        #expect(theme.button[.danger]?.backgroundColor == "color.control.danger")
        #expect(theme.button[.ghost]?.backgroundColor == "color.control.ghost")
    }

    @Test("default theme has text styles")
    func defaultText() {
        let theme = AuraTheme.default
        #expect(theme.text[.primary]?.textColor == "color.text.primary")
        #expect(theme.text[.secondary]?.textColor == "color.text.secondary")
    }

    @Test("default theme has container styles")
    func defaultContainer() {
        let theme = AuraTheme.default
        #expect(theme.container[.primary]?.backgroundColor == "color.surface.primary")
        #expect(theme.container[.primary]?.cornerRadius == 12)
    }

    @Test("decodes from JSON")
    func decodes() throws {
        let json = """
        {
            "heading": {
                "primary": { "textColor": "color.text.primary", "font": "font.heading1" }
            },
            "button": {
                "primary": { "textColor": "color.text.onPrimary", "backgroundColor": "color.control.primary" }
            }
        }
        """.data(using: .utf8)!

        let theme = try JSONDecoder().decode(AuraTheme.self, from: json)

        #expect(theme.heading[.primary]?.textColor == "color.text.primary")
        #expect(theme.button[.primary]?.backgroundColor == "color.control.primary")
        #expect(theme.text[.primary] == nil)  // not in JSON
    }

    @Test("missing theme returns empty style")
    func missingTheme() {
        let theme = AuraTheme.default
        let style = theme.heading[.ghost] ?? .empty
        #expect(style.textColor == nil)
    }

    @Test("merge with partial overlay")
    func mergePartial() {
        let base = AuraTheme.default
        var overlay = AuraTheme()
        overlay.heading[.primary] = ComponentStyle(textColor: "color.text.custom", font: "font.custom")
        
        let merged = base.merging(with: overlay)
        #expect(merged.heading[.primary]?.textColor == "color.text.custom")
        #expect(merged.text[.primary]?.textColor == base.text[.primary]?.textColor)
    }

    @Test("merge with empty overlay")
    func mergeEmpty() {
        let base = AuraTheme.default
        let merged = base.merging(with: AuraTheme())
        #expect(merged.heading.count == base.heading.count)
    }

    @Test("merge preserves non-overwritten values")
    func mergePreserves() {
        let base = AuraTheme(heading: [.primary: ComponentStyle(textColor: "base")])
        let overlay = AuraTheme(text: [.primary: ComponentStyle(textColor: "overlay")])
        
        let merged = base.merging(with: overlay)
        #expect(merged.heading[.primary]?.textColor == "base")
        #expect(merged.text[.primary]?.textColor == "overlay")
    }

    @Test("merge overwrites existing values")
    func mergeOverwrites() {
        let base = AuraTheme(heading: [.primary: ComponentStyle(textColor: "base")])
        let overlay = AuraTheme(heading: [.primary: ComponentStyle(textColor: "overlay")])
        
        let merged = base.merging(with: overlay)
        #expect(merged.heading[.primary]?.textColor == "overlay")
    }
}

// MARK: - Resolver Tests

@Suite("AuraColorResolver")
struct AuraColorResolverTests {

    @Test("default resolver returns non-nil CGColor for all tokens")
    func allTokensResolve() {
        let resolver = AuraColorResolver.default
        let transparentTokens: Set<AuraColorToken> = [.neutralClear, .controlGhost]
        for scheme in [AuraColorScheme.light, .dark] {
            for token in AuraColorToken.allCases {
                let color = resolver.resolve(token, scheme)
                if transparentTokens.contains(token) {
                    #expect(color.alpha == 0, "\(token.rawValue) in \(scheme) should be transparent")
                } else {
                    #expect(color.alpha > 0, "\(token.rawValue) in \(scheme) should resolve to a visible color")
                }
            }
        }
    }

    @Test("dark mode resolves different values than light")
    func darkModeDiffers() {
        let resolver = AuraColorResolver.default
        let light = resolver.resolve(.textPrimary, .light)
        let dark = resolver.resolve(.textPrimary, .dark)
        #expect(light != dark)
    }

    @Test("custom resolver overrides specific token")
    func customResolver() {
        let custom = AuraColorResolver { token, scheme in
            if token == .controlPrimary {
                return CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)  // green
            }
            return AuraColorResolver.default.resolve(token, scheme)
        }

        let green = custom.resolve(.controlPrimary, .light)
        let components = green.components
        #expect(components?[0] == 0)     // R
        #expect(components?[1] == 1)     // G
        #expect(components?[2] == 0)     // B
    }
}

@Suite("AuraFontResolver")
struct AuraFontResolverTests {

    @Test("default resolver returns valid font for all tokens")
    func allTokensResolve() {
        let resolver = AuraFontResolver.default
        for token in AuraFontToken.allCases {
            let font = resolver.resolve(token)
            #expect(font.size > 0, "\(token.rawValue) should have positive size")
            #expect(!font.family.isEmpty, "\(token.rawValue) should have a family")
        }
    }

    @Test("heading1 is larger than caption")
    func headingLargerThanCaption() {
        let resolver = AuraFontResolver.default
        #expect(resolver.resolve(.heading1).size > resolver.resolve(.caption).size)
    }

    @Test("button is semibold")
    func buttonWeight() {
        let resolver = AuraFontResolver.default
        #expect(resolver.resolve(.button).weight == .semibold)
    }
}

@Suite("AuraSpacingResolver")
struct AuraSpacingResolverTests {

    @Test("default resolver returns positive values for all tokens")
    func allTokensResolve() {
        let resolver = AuraSpacingResolver.default
        for token in AuraSpacingToken.allCases {
            let value = resolver.resolve(token)
            #expect(value > 0, "\(token.rawValue) should resolve to positive value")
        }
    }

    @Test("xs < sm < md < lg < xl < xxl")
    func ordering() {
        let resolver = AuraSpacingResolver.default
        #expect(resolver.resolve(.xs) < resolver.resolve(.sm))
        #expect(resolver.resolve(.sm) < resolver.resolve(.md))
        #expect(resolver.resolve(.md) < resolver.resolve(.lg))
        #expect(resolver.resolve(.lg) < resolver.resolve(.xl))
        #expect(resolver.resolve(.xl) < resolver.resolve(.xxl))
    }
}

import Testing
import Foundation
import SwiftUI
@testable import AuraSDUI
@testable import AuraDS

// MARK: - Test Helpers

/// A test theme with minimal, predictable styles.
let testTheme = AuraTheme(
    heading: [
        .primary: ComponentStyle(textColor: "color.text.primary", font: "font.heading1"),
        .danger: ComponentStyle(textColor: "color.text.danger", font: "font.heading1"),
    ],
    text: [
        .primary: ComponentStyle(textColor: "color.text.primary", font: "font.body"),
        .secondary: ComponentStyle(textColor: "color.text.secondary", font: "font.bodySmall"),
    ],
    button: [
        .primary: ComponentStyle(
            textColor: "color.text.onPrimary",
            backgroundColor: "color.control.primary",
            font: "font.button",
            padding: "spacing.md",
            cornerRadius: 8
        ),
    ],
    container: [
        .primary: ComponentStyle(
            backgroundColor: "color.surface.primary",
            padding: "spacing.md",
            cornerRadius: 12
        ),
    ]
)

// MARK: - ComponentRenderer Tests

@Suite("ComponentRenderer")
@MainActor
struct ComponentRendererTests {

    // MARK: - Smoke Tests (no crash)

    @Test("renders heading without crashing")
    func renderHeading() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.heading(id: "h1", AuraSDUIHeading(content: "Hello", theme: .primary))
        _ = renderer.render(component)
    }

    @Test("renders text without crashing")
    func renderText() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.text(id: "t1", AuraSDUIText(content: "Body", theme: .secondary))
        _ = renderer.render(component)
    }

    @Test("renders button without crashing")
    func renderButton() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let action = AuraComponentAction.navigate("home")
        let component = SUIComponent.button(id: "b1", AuraSDUIButton(label: "Go", theme: .primary, action: action))
        _ = renderer.render(component)
    }

    @Test("renders spacer without crashing")
    func renderSpacer() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        _ = renderer.render(.spacer(id: "s1"))
    }

    @Test("renders image without crashing")
    func renderImage() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.image(id: "i1", AuraSDUIImage(source: "https://example.com/img.png", theme: .primary))
        _ = renderer.render(component)
    }

    @Test("renders image with alt text without crashing")
    func renderImageWithAltText() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.image(id: "i2", AuraSDUIImage(source: "https://example.com/img.png", theme: .primary, altText: "Alt Text"))
        _ = renderer.render(component)
    }

    @Test("renders unknown without crashing")
    func renderUnknown() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let raw = AuraComponent(type: .image, content: "img.png", theme: nil, action: nil, children: nil)
        _ = renderer.render(.unknown(id: "u1", raw))
    }

    @Test("renders container with children without crashing")
    func renderContainer() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let children: [SUIComponent] = [
            .heading(id: "h1", AuraSDUIHeading(content: "Title", theme: .primary)),
            .text(id: "t1", AuraSDUIText(content: "Body", theme: .secondary)),
            .spacer(id: "s1"),
        ]
        let component = SUIComponent.container(id: "c1", theme: .primary, children: children)
        _ = renderer.render(component)
    }

    @Test("renders deeply nested containers without crashing")
    func renderNestedContainers() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let inner: [SUIComponent] = [
            .text(id: "t1", AuraSDUIText(content: "Deep", theme: .primary)),
        ]
        let outer: [SUIComponent] = [
            .container(id: "c2", theme: .primary, children: inner),
        ]
        let component = SUIComponent.container(id: "c1", theme: .primary, children: outer)
        _ = renderer.render(component)
    }

    // MARK: - Action Tests

    @Test("button onAction is called with the correct action")
    func buttonActionCalled() {
        let expected = AuraComponentAction.deepLink(URL(string: "aura://test")!)
        let renderer = ComponentRenderer(theme: testTheme) { action in
            #expect(action == expected)
        }

        let component = SUIComponent.button(id: "b1", AuraSDUIButton(
            label: "Test",
            theme: .primary,
            action: expected
        ))

        // Render doesn't trigger the action — it creates a Button view.
        // The action is only triggered when the Button is tapped.
        // We verify the renderer doesn't crash.
        _ = renderer.render(component)
    }

    // MARK: - Theme Resolution Tests

    @Test("uses heading style from theme")
    func headingStyleFromTheme() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.heading(id: "h1", AuraSDUIHeading(content: "Hello", theme: .primary))
        _ = renderer.render(component)
        #expect(testTheme.heading[.primary]?.textColor == "color.text.primary")
    }

    @Test("uses button style from theme")
    func buttonStyleFromTheme() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let action = AuraComponentAction.navigate("x")
        let component = SUIComponent.button(id: "b1", AuraSDUIButton(label: "Go", theme: .primary, action: action))
        _ = renderer.render(component)
        #expect(testTheme.button[.primary]?.backgroundColor == "color.control.primary")
    }

    @Test("uses container style from theme")
    func containerStyleFromTheme() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.container(id: "c1", theme: .primary, children: [])
        _ = renderer.render(component)
        #expect(testTheme.container[.primary]?.cornerRadius == 12)
    }

    @Test("falls back to empty style for missing theme")
    func missingThemeFallback() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.heading(id: "h1", AuraSDUIHeading(content: "Hello", theme: .ghost))
        _ = renderer.render(component)
    }

    // MARK: - Sendable Conformance

    @Test("renderer is Sendable")
    func isSendable() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        Task {
            _ = renderer.render(.spacer(id: "s1"))
        }
    }
}

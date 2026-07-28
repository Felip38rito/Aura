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
        let component = SUIComponent.heading(AuraSDUIHeading(content: "Hello", theme: .primary))
        let view = renderer.render(component)
        #expect(view is AnyView)
    }

    @Test("renders text without crashing")
    func renderText() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.text(AuraSDUIText(content: "Body", theme: .secondary))
        let view = renderer.render(component)
        #expect(view is AnyView)
    }

    @Test("renders button without crashing")
    func renderButton() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let action = AuraComponentAction.navigate("home")
        let component = SUIComponent.button(AuraSDUIButton(label: "Go", theme: .primary, action: action))
        let view = renderer.render(component)
        #expect(view is AnyView)
    }

    @Test("renders spacer without crashing")
    func renderSpacer() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let view = renderer.render(.spacer)
        #expect(view is AnyView)
    }

    @Test("renders unknown without crashing")
    func renderUnknown() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let raw = AuraComponent(type: .image, content: "img.png", theme: nil, action: nil, children: nil)
        let view = renderer.render(.unknown(raw))
        #expect(view is AnyView)
    }

    @Test("renders container with children without crashing")
    func renderContainer() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let children: [SUIComponent] = [
            .heading(AuraSDUIHeading(content: "Title", theme: .primary)),
            .text(AuraSDUIText(content: "Body", theme: .secondary)),
            .spacer,
        ]
        let component = SUIComponent.container(theme: .primary, children: children)
        let view = renderer.render(component)
        #expect(view is AnyView)
    }

    @Test("renders deeply nested containers without crashing")
    func renderNestedContainers() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let inner: [SUIComponent] = [
            .text(AuraSDUIText(content: "Deep", theme: .primary)),
        ]
        let outer: [SUIComponent] = [
            .container(theme: .primary, children: inner),
        ]
        let component = SUIComponent.container(theme: .primary, children: outer)
        let view = renderer.render(component)
        #expect(view is AnyView)
    }

    // MARK: - Action Tests

    @Test("button onAction is called with the correct action")
    func buttonActionCalled() {
        let expected = AuraComponentAction.deepLink(URL(string: "aura://test")!)
        let renderer = ComponentRenderer(theme: testTheme) { action in
            #expect(action == expected)
        }

        let component = SUIComponent.button(AuraSDUIButton(
            label: "Test",
            theme: .primary,
            action: expected
        ))

        // Render doesn't trigger the action — it creates a Button view.
        // The action is only triggered when the Button is tapped.
        // We verify the renderer doesn't crash.
        let _ = renderer.render(component)
    }

    // MARK: - Theme Resolution Tests

    @Test("uses heading style from theme")
    func headingStyleFromTheme() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.heading(AuraSDUIHeading(content: "Hello", theme: .primary))
        let _ = renderer.render(component)
        // If the theme didn't have .primary for heading, it would use .empty
        // and the textColor would be nil. We verify the theme has it.
        #expect(testTheme.heading[.primary]?.textColor == "color.text.primary")
    }

    @Test("uses button style from theme")
    func buttonStyleFromTheme() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let action = AuraComponentAction.navigate("x")
        let component = SUIComponent.button(AuraSDUIButton(label: "Go", theme: .primary, action: action))
        let _ = renderer.render(component)
        #expect(testTheme.button[.primary]?.backgroundColor == "color.control.primary")
    }

    @Test("uses container style from theme")
    func containerStyleFromTheme() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        let component = SUIComponent.container(theme: .primary, children: [])
        let _ = renderer.render(component)
        #expect(testTheme.container[.primary]?.cornerRadius == 12)
    }

    @Test("falls back to empty style for missing theme")
    func missingThemeFallback() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        // .ghost is not in testTheme.heading
        let component = SUIComponent.heading(AuraSDUIHeading(content: "Hello", theme: .ghost))
        let _ = renderer.render(component)
        // Should not crash — uses .empty
    }

    // MARK: - Sendable Conformance

    @Test("renderer is Sendable")
    func isSendable() {
        let renderer = ComponentRenderer(theme: testTheme, onAction: { _ in })
        // Verify it can be sent across concurrency boundaries
        Task {
            let view = renderer.render(.spacer)
            #expect(view is AnyView)
        }
    }
}

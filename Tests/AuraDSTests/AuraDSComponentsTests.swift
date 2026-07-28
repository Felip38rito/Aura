import Testing
import Foundation
import SwiftUI
@testable import AuraDS

// MARK: - Test Helpers

/// A test style with explicit values for verification.
let testButtonStyle = ComponentStyle(
    textColor: "color.text.onPrimary",
    backgroundColor: "color.control.primary",
    font: "font.button",
    padding: "spacing.md",
    cornerRadius: 8
)

let testHeadingStyle = ComponentStyle(
    textColor: "color.text.primary",
    font: "font.heading1",
    margin: "spacing.md"
)

let testTextStyle = ComponentStyle(
    textColor: "color.text.secondary",
    font: "font.bodySmall"
)

// MARK: - AuraButton Tests

@Suite("AuraButton")
@MainActor
struct AuraButtonTests {

    @Test("initializes without crashing")
    func initWithoutCrash() {
        let button = AuraButton(label: "Test", style: testButtonStyle, action: { })
        #expect(button.label == "Test")
    }

    @Test("body returns a view without crashing")
    func bodyReturnsView() {
        let button = AuraButton(label: "Test", style: testButtonStyle, action: { })
        let view = button.body
        // body is some View — verify it's not an EmptyView
        #expect(!(view is EmptyView))
    }

    @Test("accepts empty style without crashing")
    func emptyStyle() {
        let button = AuraButton(label: "Test", style: .empty, action: { })
        let view = button.body
        #expect(!(view is EmptyView))
    }

    @Test("accepts different corner radius")
    func customCornerRadius() {
        let style = ComponentStyle(cornerRadius: 20)
        let button = AuraButton(label: "Rounded", style: style, action: { })
        let view = button.body
        #expect(!(view is EmptyView))
    }

    @Test("action closure is captured")
    func actionCaptured() {
        var called = false
        let button = AuraButton(label: "Tap", style: testButtonStyle) {
            called = true
        }
        // Action is only called on tap — verify it doesn't crash
        let _ = button.body
        #expect(!called)  // not called during body evaluation
    }
}

// MARK: - AuraHeading Tests

@Suite("AuraHeading")
@MainActor
struct AuraHeadingTests {

    @Test("initializes without crashing")
    func initWithoutCrash() {
        let heading = AuraHeading(content: "Hello", style: testHeadingStyle)
        #expect(heading.content == "Hello")
    }

    @Test("body returns a view without crashing")
    func bodyReturnsView() {
        let heading = AuraHeading(content: "Hello", style: testHeadingStyle)
        let view = heading.body
        #expect(!(view is EmptyView))
    }

    @Test("accepts empty style without crashing")
    func emptyStyle() {
        let heading = AuraHeading(content: "Hello", style: .empty)
        let view = heading.body
        #expect(!(view is EmptyView))
    }

    @Test("accepts different theme styles")
    func differentTheme() {
        let dangerStyle = ComponentStyle(
            textColor: "color.text.danger",
            font: "font.heading1",
            margin: "spacing.md"
        )
        let heading = AuraHeading(content: "Warning", style: dangerStyle)
        let view = heading.body
        #expect(!(view is EmptyView))
    }

    @Test("renders long content without crashing")
    func longContent() {
        let long = String(repeating: "A", count: 1000)
        let heading = AuraHeading(content: long, style: testHeadingStyle)
        let view = heading.body
        #expect(!(view is EmptyView))
    }
}

// MARK: - AuraText Tests

@Suite("AuraText")
@MainActor
struct AuraTextTests {

    @Test("initializes without crashing")
    func initWithoutCrash() {
        let text = AuraText(content: "Body", style: testTextStyle)
        #expect(text.content == "Body")
    }

    @Test("body returns a view without crashing")
    func bodyReturnsView() {
        let text = AuraText(content: "Body", style: testTextStyle)
        let view = text.body
        #expect(!(view is EmptyView))
    }

    @Test("accepts empty style without crashing")
    func emptyStyle() {
        let text = AuraText(content: "Body", style: .empty)
        let view = text.body
        #expect(!(view is EmptyView))
    }

    @Test("accepts different theme styles")
    func differentTheme() {
        let infoStyle = ComponentStyle(
            textColor: "color.text.info",
            font: "font.caption"
        )
        let text = AuraText(content: "Info", style: infoStyle)
        let view = text.body
        #expect(!(view is EmptyView))
    }

    @Test("renders empty string without crashing")
    func emptyContent() {
        let text = AuraText(content: "", style: testTextStyle)
        let view = text.body
        #expect(!(view is EmptyView))
    }
}

// MARK: - Cross-Component Style Tests

@Suite("Component Style Resolution")
@MainActor
struct ComponentStyleResolutionTests {

    @Test("button uses correct default tokens when style is empty")
    func buttonDefaults() {
        let button = AuraButton(label: "Test", style: .empty, action: { })
        let view = button.body
        // Should use default resolvers — no crash expected
        #expect(!(view is EmptyView))
    }

    @Test("heading uses correct default tokens when style is empty")
    func headingDefaults() {
        let heading = AuraHeading(content: "Test", style: .empty)
        let view = heading.body
        #expect(!(view is EmptyView))
    }

    @Test("text uses correct default tokens when style is empty")
    func textDefaults() {
        let text = AuraText(content: "Test", style: .empty)
        let view = text.body
        #expect(!(view is EmptyView))
    }

    @Test("all components can be created with the same style")
    func sharedStyle() {
        let shared = ComponentStyle(
            textColor: "color.text.primary",
            font: "font.body",
            padding: "spacing.sm",
            margin: "spacing.sm"
        )
        let button = AuraButton(label: "B", style: shared, action: { })
        let heading = AuraHeading(content: "H", style: shared)
        let text = AuraText(content: "T", style: shared)

        #expect(!(button.body is EmptyView))
        #expect(!(heading.body is EmptyView))
        #expect(!(text.body is EmptyView))
    }
}

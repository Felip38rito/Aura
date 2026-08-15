import Testing
import Foundation
@testable import AuraSDUI
@testable import AuraDS

// MARK: - AuraComponentAction Tests

@Suite("AuraComponentAction")
struct AuraComponentActionTests {

    @Test("decodes deepLink action")
    func deepLink() throws {
        let json = #"{"type": "deepLink", "value": "aura://profile/123"}"#.data(using: .utf8)!
        let action = try JSONDecoder().decode(AuraComponentAction.self, from: json)

        guard case .deepLink(let url) = action else {
            Issue.record("Expected deepLink, got \(action)")
            return
        }
        #expect(url.absoluteString == "aura://profile/123")
    }

    @Test("decodes navigate action")
    func navigate() throws {
        let json = #"{"type": "navigate", "value": "settings"}"#.data(using: .utf8)!
        let action = try JSONDecoder().decode(AuraComponentAction.self, from: json)

        guard case .navigate(let screen) = action else {
            Issue.record("Expected navigate, got \(action)")
            return
        }
        #expect(screen == "settings")
    }

    @Test("decodes openURL action")
    func openURL() throws {
        let json = #"{"type": "openURL", "value": "https://example.com"}"#.data(using: .utf8)!
        let action = try JSONDecoder().decode(AuraComponentAction.self, from: json)

        guard case .openURL(let url) = action else {
            Issue.record("Expected openURL, got \(action)")
            return
        }
        #expect(url.absoluteString == "https://example.com")
    }

    @Test("decodes custom action")
    func custom() throws {
        let json = #"{"type": "custom", "value": "logout"}"#.data(using: .utf8)!
        let action = try JSONDecoder().decode(AuraComponentAction.self, from: json)

        guard case .custom(let event) = action else {
            Issue.record("Expected custom, got \(action)")
            return
        }
        #expect(event == "logout")
    }

    @Test("throws on unknown action type")
    func unknownType() {
        let json = #"{"type": "unknown", "value": "x"}"#.data(using: .utf8)!
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(AuraComponentAction.self, from: json)
        }
    }

    @Test("throws on invalid deepLink URL")
    func invalidDeepLink() {
        let json = #"{"type": "deepLink", "value": ""}"#.data(using: .utf8)!
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(AuraComponentAction.self, from: json)
        }
    }
}

// MARK: - SUIComponent Decoding Tests

@Suite("SUIComponent Decoding")
struct SUIComponentDecodingTests {

    @Test("decodes heading component")
    func heading() throws {
        let json = #"{"id": "h1", "type": "heading", "content": "Hello", "theme": "primary"}"#.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .heading(let id, let data) = component else {
            Issue.record("Expected heading, got \(component)")
            return
        }
        #expect(id == "h1")
        #expect(data.content == "Hello")
        #expect(data.theme == .primary)
    }

    @Test("decodes heading with default theme when omitted")
    func headingDefaultTheme() throws {
        let json = #"{"id": "h1", "type": "heading", "content": "Hello"}"#.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .heading(_, let data) = component else {
            Issue.record("Expected heading, got \(component)")
            return
        }
        #expect(data.theme == .primary)
    }

    @Test("decodes text component")
    func text() throws {
        let json = #"{"id": "t1", "type": "text", "content": "Detail", "theme": "secondary"}"#.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .text(let id, let data) = component else {
            Issue.record("Expected text, got \(component)")
            return
        }
        #expect(id == "t1")
        #expect(data.content == "Detail")
        #expect(data.theme == .secondary)
    }

    @Test("decodes button component with action")
    func button() throws {
        let json = """
        {
            "id": "b1",
            "type": "button",
            "content": "Salvar",
            "theme": "primary",
            "action": { "type": "deepLink", "value": "aura://save" }
        }
        """.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .button(let id, let data) = component else {
            Issue.record("Expected button, got \(component)")
            return
        }
        #expect(id == "b1")
        #expect(data.label == "Salvar")
        #expect(data.theme == .primary)
        guard case .deepLink(let url) = data.action else {
            Issue.record("Expected deepLink action")
            return
        }
        #expect(url.absoluteString == "aura://save")
    }

    @Test("throws on button without action")
    func buttonMissingAction() {
        let json = #"{"id": "b1", "type": "button", "content": "Click"}"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            _ = try JSONDecoder().decode(SUIComponent.self, from: json)
        }
    }

    @Test("decodes spacer component")
    func spacer() throws {
        let json = #"{"id": "s1", "type": "spacer"}"#.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .spacer(let id) = component else {
            Issue.record("Expected spacer, got \(component)")
            return
        }
        #expect(id == "s1")
    }

    @Test("decodes container with children")
    func containerWithChildren() throws {
        let json = """
        {
            "id": "c1",
            "type": "container",
            "theme": "primary",
            "children": [
                { "id": "h1", "type": "heading", "content": "Title", "theme": "primary" },
                { "id": "t1", "type": "text", "content": "Body", "theme": "secondary" }
            ]
        }
        """.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .container(let id, let theme, let children) = component else {
            Issue.record("Expected container, got \(component)")
            return
        }
        #expect(id == "c1")
        #expect(theme == .primary)
        #expect(children.count == 2)

        // First child: heading
        guard case .heading(_, let heading) = children[0] else {
            Issue.record("Expected heading as first child")
            return
        }
        #expect(heading.content == "Title")

        // Second child: text
        guard case .text(_, let text) = children[1] else {
            Issue.record("Expected text as second child")
            return
        }
        #expect(text.content == "Body")
    }

    @Test("decodes nested containers")
    func nestedContainers() throws {
        let json = """
        {
            "id": "c1",
            "type": "container",
            "children": [
                {
                    "id": "c2",
                    "type": "container",
                    "children": [
                        { "id": "t1", "type": "text", "content": "Deep" }
                    ]
                }
            ]
        }
        """.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .container(_, _, let outer) = component else {
            Issue.record("Expected container")
            return
        }
        #expect(outer.count == 1)

        guard case .container(_, _, let inner) = outer[0] else {
            Issue.record("Expected nested container")
            return
        }
        #expect(inner.count == 1)

        guard case .text(_, let text) = inner[0] else {
            Issue.record("Expected text in innermost container")
            return
        }
        #expect(text.content == "Deep")
    }

    @Test("decodes image as typed component")
    func imageDecoding() throws {
        let json = #"{"id": "i1", "type": "image", "content": "https://example.com/img.png", "theme": "primary", "altText": "Alt Text"}"#.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .image(let id, let data) = component else {
            Issue.record("Expected image, got \(component)")
            return
        }
        #expect(id == "i1")
        #expect(data.source == "https://example.com/img.png")
        #expect(data.theme == .primary)
        #expect(data.altText == "Alt Text")
    }

    @Test("throws on heading without content")
    func headingMissingContent() {
        let json = #"{"id": "h1", "type": "heading"}"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            _ = try JSONDecoder().decode(SUIComponent.self, from: json)
        }
    }

    @Test("throws on missing id")
    func missingID() {
        let json = #"{"type": "heading", "content": "Hello"}"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            _ = try JSONDecoder().decode(SUIComponent.self, from: json)
        }
    }

    @Test("decodes unknown component type to .unknown")
    func unknownType() throws {
        let json = #"{"id": "u1", "type": "carousel", "content": "x"}"#.data(using: .utf8)!
        let component = try JSONDecoder().decode(SUIComponent.self, from: json)

        guard case .unknown(let id, let raw) = component else {
            Issue.record("Expected unknown, got \(component)")
            return
        }
        #expect(id == "u1")
        #expect(raw.type == .unknown)
    }
}

// MARK: - AuraComponent Decoding Tests

@Suite("AuraComponent Decoding")
struct AuraComponentDecodingTests {

    @Test("decodes full component")
    func full() throws {
        let json = """
        {
            "type": "button",
            "content": "Click",
            "theme": "primary",
            "action": { "type": "navigate", "value": "home" }
        }
        """.data(using: .utf8)!
        let component = try JSONDecoder().decode(AuraComponent.self, from: json)

        #expect(component.type == .button)
        #expect(component.content == "Click")
        #expect(component.theme == .primary)
        #expect(component.action != nil)
        #expect(component.children == nil)
    }

    @Test("decodes container with children")
    func container() throws {
        let json = """
        {
            "type": "container",
            "children": [
                { "type": "text", "content": "A" },
                { "type": "text", "content": "B" }
            ]
        }
        """.data(using: .utf8)!
        let component = try JSONDecoder().decode(AuraComponent.self, from: json)

        #expect(component.type == .container)
        #expect(component.children?.count == 2)
        #expect(component.children?.first?.content == "A")
    }
}

// MARK: - AuraComponentType Tests

@Suite("AuraComponentType")
struct AuraComponentTypeTests {

    @Test("all cases decode from their raw values")
    func allDecode() {
        for type in AuraComponentType.allCases {
            let json = "\"\(type.rawValue)\"".data(using: .utf8)!
            let decoded = try? JSONDecoder().decode(AuraComponentType.self, from: json)
            #expect(decoded == type)
        }
    }

    @Test("unknown string decodes to .unknown")
    func unknownString() throws {
        let json = "\"carousel\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AuraComponentType.self, from: json)
        #expect(decoded == .unknown)
    }
}

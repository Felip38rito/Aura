import Foundation
import AuraDS

/// The recursive component tree that represents a server-driven UI screen.
///
/// Decoded from a JSON payload, this enum is the **bridge** between the raw
/// `AuraComponent` contracts and the typed SDUI components that the renderer consumes.
///
/// ```json
/// {
///   "type": "container",
///   "theme": "primary",
///   "children": [
///     { "type": "heading", "content": "Welcome", "theme": "primary" },
///     { "type": "button", "content": "Click", "theme": "primary", "action": { ... } }
///   ]
/// }
/// ```
public indirect enum SUIComponent: Sendable {
    case heading(AuraSDUIHeading)
    case text(AuraSDUIText)
    case button(AuraSDUIButton)
    case container(theme: AuraComponentTheme, children: [SUIComponent])
    case spacer
    case unknown(AuraComponent)
}

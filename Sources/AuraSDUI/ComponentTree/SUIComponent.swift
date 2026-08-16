import Foundation
import AuraDS

/// The recursive component tree that represents a server-driven UI screen.
///
/// Decoded from a JSON payload, this enum is the **bridge** between the raw
/// `AuraComponent` contracts and the typed SDUI components that the renderer consumes.
///
/// Every node carries a server-assigned `id` so the renderer can give each
/// element a **stable identity** across updates (reordering, insertion, removal).
///
/// ```json
/// {
///   "id": "screen-1",
///   "type": "container",
///   "theme": "primary",
///   "children": [
///     { "id": "h-1", "type": "heading", "content": "Welcome", "theme": "primary" },
///     { "id": "b-1", "type": "button", "content": "Click", "theme": "primary", "action": { ... } }
///   ]
/// }
/// ```
public indirect enum SUIComponent: Sendable, Identifiable {
    case heading(id: String, AuraSDUIHeading)
    case text(id: String, AuraSDUIText)
    case button(id: String, AuraSDUIButton)
    case image(id: String, AuraSDUIImage)
    case container(id: String, theme: AuraComponentTheme, children: [SUIComponent])
    case spacer(id: String)
    case unknown(id: String, AuraComponent)

    /// The server-assigned identity of this node. Stable across updates.
    public var id: String {
        switch self {
        case .heading(let id, _),
             .text(let id, _),
             .button(let id, _),
             .image(let id, _),
             .container(let id, _, _),
             .spacer(let id),
             .unknown(let id, _):
            return id
        }
    }
}

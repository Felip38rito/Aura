import Foundation

/// Wrapper for component content.
///
/// Some components carry text content (headings, text), others don't (spacer, image).
/// This typealias makes the intent clear in the `AuraComponent` struct.
public typealias AuraComponentContent = String

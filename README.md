# Aura

A modular, token-based Server-Driven UI (SDUI) framework for Swift.

Aura lets you define user interfaces as structured data and render them through a clean, decoupled architecture. The framework separates **what** the UI is (domain contracts) from **how it looks** (a token-based Design System), making dynamic layouts possible without shipping a new app release.

## Modules

| Module | Purpose |
|--------|---------|
| **AuraDS** | Design System primitives — tokens, colors, typography, and reusable visual components. |
| **AuraSDUI** | Server-Driven UI domain layer — decodable contracts, component tree, and renderer entry point. |

## Features

- 🔀 **Server-Driven UI** — JSON payload to SwiftUI view hierarchy.
- 🎨 **Token-Based Design System** — semantic colors and typography resolved at runtime.
- 🧩 **Modular Architecture** — each layer is an independent Swift package target.
- 🧪 **Testable by Design** — domain contracts are pure Swift structs with no UI framework dependencies.

## Requirements

- Swift 6.4+
- macOS 14+ / iOS 17+ (SwiftUI previews)
- Tuist 4.202.0 (used only for the example Xcode project)

## Development

```bash
swift build
swift test
```

To regenerate the example Xcode project:

```bash
cd Tuist
tuist generate
```

## Project Structure

```
Aura/
├── Package.swift          # SPM source of truth
├── Sources/
│   ├── AuraDS/            # Design System
│   └── AuraSDUI/          # SDUI domain + renderer
├── Tests/
│   ├── AuraDSTests/
│   └── AuraSDUITests/
├── Tuist/                 # Example Xcode project only
└── skills/                # Hermes agent skills for the project workflow
```

## License

Aura is released under the [MIT License](LICENSE).

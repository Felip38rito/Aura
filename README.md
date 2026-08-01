# Aura

A modular, token-based Server-Driven UI (SDUI) framework for Swift.

Aura lets you define user interfaces as structured data and render them through a clean, decoupled architecture. The framework separates **what** the UI is (domain contracts) from **how it looks** (a token-based Design System), making dynamic layouts possible without shipping a new app release.

## Modules

| Module | Purpose |
|--------|---------|
| **AuraKernel** | Plugin-based app lifecycle orchestration — `UIApplicationDelegate` and `UISceneDelegate` forwarding with dependency-injected plugins. |
| **AuraDS** | Design System primitives — semantic tokens (color, font, spacing), resolvers, and reusable SwiftUI components (`AuraButton`, `AuraHeading`, `AuraText`). |
| **AuraSDUI** | Server-Driven UI domain layer — decodable JSON contracts, recursive component tree (`SUIComponent`), and `ComponentRenderer` that maps tree to SwiftUI views. |

## Features

- 🔀 **Server-Driven UI** — JSON payload to SwiftUI view hierarchy.
- 🎨 **Token-Based Design System** — semantic colors, typography, and spacing resolved at runtime.
- 🧩 **Plugin Architecture** — compose app features as isolated `AuraKernelPlugin` instances with dependency ordering.
- 🧪 **Testable by Design** — domain contracts are pure Swift structs with no UI framework dependencies.
- 📱 **Example App** — Tuist-generated Xcode project showcasing all components and SDUI pipeline.

## Requirements

- Swift 6.4+
- macOS 14+ / iOS 17+ (SwiftUI previews)
- Tuist 4.202.0+ (used only for the example Xcode project)

## Development

```bash
swift build
swift test
```

To open the example Xcode project:

```bash
cd Tuist
tuist install
tuist generate --no-open
open AuraExample.xcworkspace
```

## Project Structure

```
Aura/
├── Docs/ADRs/              # Architecture Decision Records
├── Package.swift           # SPM source of truth
├── Sources/
│   ├── AuraKernel/         # App lifecycle orchestration (plugin-based)
│   ├── AuraDS/             # Design System tokens & primitives
│   └── AuraSDUI/           # SDUI contracts + renderer
├── Tests/
│   ├── AuraKernelTests/
│   ├── AuraDSTests/
│   └── AuraSDUITests/
├── Tuist/                  # Example Xcode project only
│   ├── Project.swift
│   ├── Package.swift        # Local dependency resolution
│   └── Sources/             # Example app source
├── skills/                 # Hermes agent skills for the project workflow
├── .gitignore
├── LICENSE
└── README.md
```

## Architecture Overview

```
JSON Payload
    │
    ▼
AuraComponent (raw Decodable)
    │
    ▼
SUIComponent (typed recursive enum)
    │
    ▼
ComponentRenderer (SwiftUI AnyView)
    │
    ▼
AuraDS Components (AuraButton, AuraHeading, AuraText)
    │
    ▼
AuraTheme → Resolvers (Color, Font, Spacing)
```

## License

Aura is released under the [MIT License](LICENSE).

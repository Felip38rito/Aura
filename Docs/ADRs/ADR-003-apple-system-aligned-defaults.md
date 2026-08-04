# ADR-003: Apple System-Aligned Defaults for AuraDS

**Status:** Accepted
**Date:** 2026-08-04
**Author:** Felipe Brito
**Deciders:** Felipe Brito, Hermes Agent

---

## Context

AuraDS ships a token-based design system (semantic color/font/spacing tokens resolved by `AuraColorResolver` / `AuraFontResolver` / `AuraSpacingResolver`, plus a `AuraTheme` value type). The architecture is sound, but the **default values** of the built-in resolvers are "generic":

- **Fonts** are fixed-size `Font.system(size:)` values that do **not** scale with the user's Dynamic Type / accessibility preference. Apps that feel native on Apple platforms scale typography automatically.
- **Colors** are arbitrary grays (e.g. `textPrimary` = gray 0 / 0.95) that do not participate in system appearance behavior (invert-adaptive `label`, dynamic separator opacity, accessibility-high-contrast variants).

Consumers want Aura to produce a "look and feel" that reads as an Apple platform app **by default**, while still being fully overridable.

The framework already supports overriding at every layer:

- `AuraColorResolver` / `AuraFontResolver` are public structs with public `init(resolve:)` and a `.default` static — any consumer can inject their own resolver.
- Resolvers are injected via `Environment` (`.environment(\.colorResolver, ...)`), so a whole app can swap resolvers at the root.
- `AuraTheme` is a `Decodable` value type with `merging(with:)` — server-driven apps can overlay JSON themes.

Therefore changing the **defaults** is safe: it changes the out-of-the-box appearance without breaking consumers who already customize.

## Decision

In AuraDS **v0.2.0**, align the built-in default resolvers to Apple system conventions:

1. **Typography → Dynamic Type.** Add optional `Font.TextStyle` support to `AuraResolvedFont`. `AuraFontResolver.default` maps every `AuraFontToken` to a matching SF **text style** (`.largeTitle`, `.title1`, `.title2`, `.title3`, `.body`, `.subheadline`, `.caption1`, `.footnote`, `.headline`), so text scales automatically with the user's Dynamic Type preference. Custom fonts (`family`/`size`) continue to work unchanged.

2. **Colors → system semantic colors.** Rewrite `AuraColorResolver.default` to resolve tokens from `UIColor` / `NSColor` semantic colors (`.label`, `.secondaryLabel`, `.systemBackground`, `.secondarySystemBackground`, `.systemRed`, `.systemBlue`, `.separator`, etc.) via `#if canImport(UIKit)` / `AppKit` guards. This delegates light/dark (and future accessibility variants) to the OS and removes the invented grays.

### Mapping — Font tokens → SF text styles

```
largeTitle   → .largeTitle             (34, regular)
heading1     → .title1                 (28, regular)
heading2     → .title2                 (22, regular)
heading3     → .title3                 (20, regular)
body         → .body                   (17, regular)
bodySmall    → .subheadline            (15, regular)
caption      → .caption1               (12, regular)
button       → .headline, semibold     (17, semibold)
buttonSmall  → .subheadline, semibold  (15, semibold)
label        → .footnote               (13, regular)
```

### Mapping — Color tokens → system semantic colors

```
textPrimary        → .label
textSecondary      → .secondaryLabel
textTertiary       → .tertiaryLabel
textOnPrimary      → .white              (on primary control)
textOnDark         → .white              (unchanged intent)
textDanger         → .systemRed
textSuccess        → .systemGreen
textWarning        → .systemOrange
textInfo           → .systemBlue
textDisabled       → .secondaryLabel (with opacity in component)
controlPrimary     → .tintColor
controlPrimaryPressed → .systemBlue (pressed tint)
controlSecondary   → .systemGray5 / .tertiarySystemFill
controlGhost       → .clear (transparent, unchanged)
surfacePrimary     → .systemBackground
surfaceSecondary   → .secondarySystemBackground
surfaceTertiary    → .tertiarySystemBackground
backgroundPrimary  → .systemBackground
backgroundSecondary→ .secondarySystemBackground
borderPrimary      → .separator
borderSecondary    → .separator (lighter intent via opacity)
borderDanger       → .systemRed
neutralWhite       → .white
neutralBlack       → .black
neutralClear       → .clear (transparent, unchanged)
```

## Key Decisions

### 1. Dynamic Type via text styles over fixed sizes
- **Chosen:** `Font.system(textStyle:)` so scaling is automatic.
- **Why:** Native feel + accessibility for free. Fixed sizes are the main reason the current default doesn't feel "Apple".
- **Rejected:** `UIFontMetrics` manually (more code, no benefit over `Font.system(textStyle:)`).

### 2. System semantic colors over custom grays
- **Chosen:** `UIColor`/`NSColor` semantic values.
- **Why:** They adapt to light/dark and future accessibility/high-contrast automatically, and match how Apple's own components look.
- **Rejected:** Keeping invented grays (don't participate in system appearance; don't look native).

### 3. Backward-compatible `AuraResolvedFont`
- **Chosen:** add an optional `textStyle` field rather than replacing `family`/`size`.
- **Why:** Custom-font consumers keep working; `size`/`family` remain the fallback path. `AuraResolvedFont` is `Equatable`/`Sendable`, and the new field is additive.

## Consequences

### Positive
- **Native look & feel by default** — the demo (and any consumer using defaults) reads as an Apple app.
- **Accessibility for free** — Dynamic Type scaling works out of the box.
- **System appearance correctness** — colors adapt to light/dark/high-contrast natively.
- **No breaking change for customizers** — resolvers and theme remain injectable/overridable.

### Negative
- `AuraResolvedFont` gains a new field — code that constructs it directly and exhaustively reads its members is unaffected, but any custom `AuraFontResolver` returning `AuraResolvedFont.system(size:weight:)` still works (that factory remains).
- The visual default changes for everyone who uses the built-in resolvers — a one-time appearance change.
- Semantic color resolution is platform-gated (`#if canImport(UIKit)` / `AppKit`); pure-Linux SPM builds of the package fall back to a CoreGraphics approximation.

### Mitigations
- Keep `.default` resolvers as the single source of the system-aligned values.
- Add/update unit tests asserting: every color token resolves to a non-transparent color (except transparent-intent tokens), dark differs from light for text/surface tokens, and font tokens have valid text-style mappings.
- Update the example app's `AuraExample` to consume the new defaults (it already resolves through the resolvers).

## Alternatives Considered

### Keep fixed-size fonts and gray palettes
Rejected — this is exactly the "generic look" the ADR aims to remove.

### Make system colors the only option (remove custom resolvers)
Rejected — that would break the SDUI server-driven theme story. System colors are the **default**, custom resolvers remain first-class.

### Adopt a third-party theme (e.g. shadcn-like)
Rejected — the goal is native Apple feel, not a web-toolkit aesthetic; and no new dependencies.

## References

- AuraDS token/resolver source in `Sources/AuraDS/`
- Apple HIG: [Color](https://developer.apple.com/design/human-interface-guidelines/color), [Typography](https://developer.apple.com/design/human-interface-guidelines/typography)

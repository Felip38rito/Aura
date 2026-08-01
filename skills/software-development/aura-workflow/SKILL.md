---
name: aura-workflow
description: Use when working on the Aura Swift framework. Defines the local dev loop with SPM, Tuist example project, and Hermes collaboration rules.
version: 1.0.0
author: Felipe Brito
license: MIT
metadata:
  hermes:
    tags: [aura, swift, spm, tuist, workflow, vscodium]
    related_skills: [aura-sdui-dev]
---

# Aura Workflow

## Overview

Aura is a Swift framework delivered as an SPM package. The source of truth for modules and dependencies is `Package.swift`. Tuist 4.202.0 is used **only** to generate and maintain an example Xcode project under `Tuist/`, for local visualization and manual testing. The framework itself remains pure SPM.

Development happens primarily in VSCodium with Hermes via ACP or terminal.

## When to Use

- Starting a new session on Aura.
- Adding or removing an SPM module.
- Adding a new SDUI component.
- Regenerating the example project after SPM changes.
- Running local build/tests.
- Preparing a commit or PR.

## Target Repository Structure

```
Aura/
├── Package.swift              # SPM source of truth
├── Sources/
│   ├── AuraDS/
│   └── AuraSDUI/
├── Tests/
│   └── AuraSDUITests/
├── Tuist/                     # Example project only
│   ├── Project.swift
│   └── ...
├── .gitignore
└── skills/
    └── software-development/
        ├── aura-workflow/
        └── aura-sdui-dev/
```

## Dev Loop

### 1. Start Session
- Confirm the current branch: `git branch --show-current`.
- Run `swift build` to establish a clean baseline.
- If the example project exists and may be stale, run `tuist generate --no-open` inside `Tuist/` (the `--no-open` flag prevents Xcode from launching).

### 2. Make Changes
- **Small changes** (rename, move file, trivial fix, single preview): proceed directly and report what was done.
- **Medium changes** (new file, new component, non-breaking refactor): propose a one-line plan, confirm, then implement.
- **Large changes** (new module, public API change, architectural decision): draft a short snippet or RFC and wait for explicit approval.

### 3. Build & Test
- After code changes, run `swift build`.
- When test targets exist, run `swift test`.
- When `Package.swift` or Tuist files change, regenerate the example project with `tuist generate --no-open` (prevents Xcode from launching).
- Report the output. If it fails, stop and diagnose together.

### 4. Commit
- Work on feature branches cut from `main`.
- Commit messages in **English**, imperative mood:
  `Add AuraText`, `Refactor Component into recursive enum`, `Update Package.swift`.
- Keep commits small and focused.
- Push and open a PR when the change is reviewable.

## Tuist Rules

- Version pinned: **Tuist 4.202.0**.
- Tuist owns only the example project inside `Tuist/`.
- The framework modules are defined in `Package.swift`.
- When a new framework module is added, update `Package.swift` first, then update the example project if it needs to reference the new module.

## Hermes Collaboration Rules

- The human sets architectural direction.
- Hermes may act directly on small decisions and must report the action.
- Hermes must ask before large or irreversible decisions.
- Skills and significant architectural snippets must be drafted and reviewed before being written to the repository.

## Verification Checklist

- [ ] `swift build` passes.
- [ ] `swift test` passes (when tests exist).
- [ ] `tuist generate` succeeds (when Tuist files change).
- [ ] Commit message follows English-imperative convention.
- [ ] The change is small, focused, and reviewable.

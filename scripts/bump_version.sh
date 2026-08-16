#!/usr/bin/env bash
# bump_version.sh — Determines the next version from a squash-merge commit message.
#
# Reads the commit message (the PR title under squash merge) and looks for a
# `major:` / `minor:` / `patch:` prefix. If found, computes the next version
# from the latest git tag and prints it. If not found, prints "no-bump".
#
# Usage: bump_version.sh "<commit message>"
set -euo pipefail
shopt -s nocasematch

MSG="${1:-}"

# Extract the bump prefix from the start of the message.
# Accepts: "major: ...", "minor: ...", "patch: ..." (case-insensitive, optional leading spaces)
BUMP=""
if [[ "$MSG" =~ ^[[:space:]]*(major|minor|patch)[[:space:]]*: ]]; then
  _m="${BASH_REMATCH[1]}"
  BUMP="$(printf '%s' "$_m" | tr '[:upper:]' '[:lower:]')"
fi

if [[ -z "$BUMP" ]]; then
  echo "no-bump"   # signal: no release prefix found
  exit 0
fi

# Latest tag, defaulting to v0.0.0 if none exists.
LATEST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")"
# Strip leading 'v' and split into major.minor.patch
CUR="${LATEST_TAG#v}"
IFS='.' read -r MAJOR MINOR PATCH <<< "$CUR"
MAJOR="${MAJOR:-0}"; MINOR="${MINOR:-0}"; PATCH="${PATCH:-0}"

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

echo "v${MAJOR}.${MINOR}.${PATCH}"

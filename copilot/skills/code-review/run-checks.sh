#!/usr/bin/env bash
# Code Review - Automated Quality Checks
# Usage: ./run-checks.sh <MERGE_BASE> [WORKTREE_PATH]
# Each check runs with a 5-minute timeout. Failures are reported but don't stop the review.

set -euo pipefail

MERGE_BASE="${1:?Usage: run-checks.sh <MERGE_BASE> [WORKTREE_PATH]}"
WORKDIR="${2:-.}"

cd "$WORKDIR"

TIMEOUT_CMD=$(command -v gtimeout || command -v timeout || echo "")
if [ -z "$TIMEOUT_CMD" ]; then
  echo "⚠️  WARNING: No timeout command found. Checks will run without a timeout."
fi

run() {
  local label="$1"; shift
  echo "▶ Running: $label"
  if [ -n "$TIMEOUT_CMD" ]; then
    "$TIMEOUT_CMD" 300 "$@" && echo "  ✅ $label passed" || echo "  ❌ $label failed (exit $?)"
  else
    "$@" && echo "  ✅ $label passed" || echo "  ❌ $label failed (exit $?)"
  fi
}

# --- Detect project type and run appropriate checks ---

# Nx Workspace
if [ -f "nx.json" ]; then
  echo "📦 Detected: Nx Workspace"
  run "format:check" pnpm nx format:check
  run "affected:lint" pnpm nx affected:lint --base="$MERGE_BASE"
  run "affected:test" pnpm nx affected:test --base="$MERGE_BASE"

# Rust
elif [ -f "Cargo.toml" ]; then
  echo "🦀 Detected: Rust"
  run "clippy" cargo clippy --all-targets --all-features -- -D warnings
  run "cargo check" cargo check --all
  run "cargo fmt" cargo fmt --check --all

# Go
elif [ -f "go.mod" ]; then
  echo "🐹 Detected: Go"
  run "go fmt" go fmt ./...
  run "go vet" go vet ./...
  run "go test" go test -v ./...

# Node.js (pnpm)
elif [ -f "package.json" ]; then
  echo "📦 Detected: Node.js"
  if grep -q '"lint"' package.json; then
    run "lint" pnpm lint
  fi
  if grep -q '"format:check"' package.json; then
    run "format:check" pnpm format:check
  fi
  if grep -q '"test"' package.json; then
    run "test" pnpm test
  fi

else
  echo "⚠️  No recognized project type found. Skipping automated checks."
fi

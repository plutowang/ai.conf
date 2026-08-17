# opencode Plugins

Plugins deployed to `~/.config/opencode/plugins/`.

## zmask-pii.js

Masks secrets and PII in outgoing agent messages before they leave your machine. It runs the vendored `zmask` binaries from `~/.config/opencode/bin/`. Source: <https://codeberg.org/bwang-dev/zmask>.

### Verify the vendored binaries

The `zmask` binaries are shipped with a checksum manifest. Verify them once after install (or clone):

```bash
cd ~/.config/opencode/bin
shasum -a 256 -c SHA256SUMS    # macOS
# sha256sum -c SHA256SUMS      # Linux
```

Every binary should report `OK`. A `FAILED` line means the file changed after shipping — do not run it.

The binaries are per platform+arch (`zmask-darwin-arm64`, `zmask-darwin-x64`, `zmask-linux-arm64`, `zmask-linux-x64`). Unsupported platforms fail open via the plugin's normal failure model.

### Updating a binary

Replace the binary, then regenerate the manifest from inside `bin/`:

```bash
shasum -a 256 zmask-* > SHA256SUMS
```

## design-reminders.js

Injects transient DESIGN / BUILD mode reminders into the design ↔ build/debug agent handoffs (mirrors OpenCode's built-in SessionReminders). No configuration needed.

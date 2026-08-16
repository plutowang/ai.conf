---
name: zig
description: Auto-apply when working with Zig. Trigger this skill when the user asks to create, modify, or debug Zig code, build.zig scripts, or Zig tests.
---

# Zig Language Expert

You are an expert in the Zig programming language. Zig is not yet stable (v1.0), so `std.Build` and stdlib APIs change between minor versions.

<red_lines>

- **Rule #1:** Never generate Zig code without knowing the active toolchain version.
- **Mismatch Alert**: If the requested features exceed `zig version`, stop and warn.
- **NEVER** use any API from the "Old" column of a migration file — always use "New".
- If unsure whether an API changed, check the migration file before writing code.
- **CRITICAL**: Always match documentation to the project's Zig version. Syntax and stdlib APIs change between minor releases.
</red_lines>

<execution_protocol>
**Version Context Protocol (Mandatory)**

Before answering any coding question, execute the following mental or actual checks:

1. **Determine Environment Version**: Run `zig version`.
2. **Determine Project Version**: Read `build.zig.zon` for `.minimum_zig_version` or `.version`.
3. **Inspect build.zig**: `const Builder = std.build.Builder;` (old) vs `pub fn build(b: *std.Build) void` (0.11+).
4. **Mismatch Alert**: If the requested features exceed `zig version`, stop and warn.
5. **Syntax Selection**:
   - **Version < 0.11**: Use `std.build.Builder`.
   - **Version >= 0.11**: Use `std.Build`.
   - **Version >= 0.12**: Use `b.addExecutable(...)` object-oriented API.
   - **Version >= 0.13**: `std.http` and `std.net` changes.
   - **Version >= 0.14**: `GPA.init` and `root_module` in build scripts.
   - **Version >= 0.15**: `std.Io` (new I/O); `async`/`await` removed.
   - **Version >= 0.16**: "Juicy Main" (`std.process.Init`); `@cImport` removed; `@Type` split into `@Int`/`@Struct`/etc.; `std.Io` param threading mandatory; unmanaged containers; process/sync/time APIs migrated to `Io`. **Read the migration file before generating code** (see Version Migration Protocol).

**Development Workflow**

Instruct the user to use these commands:

- **Check**: `zig build check` (if present).
- **Test**: `zig build test --summary all`
- **Run**: `zig build run`
- **Format**: `zig fmt .` (Enforce this style).

**Version Migration Protocol**

Zig has breaking API changes every minor version.

**Available migration files** (in this skill's `migrations/` directory):

- **0.16** → `migrations/0.16.md` — "Juicy Main", I/O threading, `@cImport` removal, `@Type` split, unmanaged containers, process/sync/time migration

**Workflow:**

1. Detect the project's Zig version (see Version Context Protocol)
2. Read that migration file immediately
3. Cross-check **every** stdlib call against the OLD→NEW tables in the migration file
</execution_protocol>

<standards>
**Project Structure**

Modern Zig projects follow this structure:

- **`build.zig`**: The build script.
  - _Note_: The API for this file is strictly coupled to the Zig version.
- **`build.zig.zon`**: (Zig 0.11+) The package manifest.
  - Contains dependencies and hash locks.
- **`src/main.zig`**: Standard entry point.

**Coding Standards & Safety**

**Memory Management**

Zig is manual. Always define ownership and allocator lifetime.

```zig
// >= 0.16: Allocators and I/O come from main's init parameter
pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;       // general-purpose allocator
    const arena = init.arena;   // scratch arena (no deinit needed)
    const io = init.io;         // required for ALL I/O calls
    _ = .{ gpa, arena, io };
}

// <= 0.15: Manual allocator setup
var gpa_inst = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa_inst.deinit();
const allocator = gpa_inst.allocator();
```

For library code (no main), accept `allocator` and `io` as function parameters.

**Error Handling**

- Use error unions (`!T`) everywhere.
- Use `try` to bubble up errors.
- Use `catch |err| switch (err)` or `if (res) |val| else |err|` to handle them.

**Cross-Version Syntax Trap**

- **Loops**: `for (items) |item|` (Old) vs `for (items) |*item|` (Pointer capture) vs `for (items, 0..) |item, i|` (Index capture).
  - _Action_: Verify which loop syntax is valid for the detected version.

**Docs**: Context7 `/websites/ziglang` · Fallback: <https://ziglang.org/documentation>
</standards>

---
name: rust
description: Auto-apply when working with Rust. Trigger this skill when the user asks to create, modify, or debug Rust code, Cargo projects, crates, or Rust tests.
---

# Lang: Rust

<red_lines>

1. **Safety:** NEVER use `.unwrap()`. Use `?` propagation or `.expect("msg")`.
2. **Async:** Assume `tokio`. Use `.await`. Never block async threads.
3. **Clippy:** Code must be strictly `clippy`-compliant (idiomatic).
</red_lines>

<standards>
**Rules**

1. **Style:** Prefer **Iterators** (`.map().collect()`) over `for` loops.
2. **Errors:** Use `anyhow::Result` for apps, `thiserror` for libs.
3. **Tests:** Co-locate unit tests in `mod tests` with `#[cfg(test)]`.

**Docs**: Context7 `/websites/doc_rust-lang_stable_book` · Fallback: <https://doc.rust-lang.org>
</standards>

<execution_protocol>
**Workflow**

- Use `skill workflow-env` before build/run commands.
- Build: `cargo build --release`
- Test: `cargo test`
- Format: `cargo fmt`
</execution_protocol>

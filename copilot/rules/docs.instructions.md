---
name: "Documentation Standards"
description: "Documentation conventions for markdown and text files"
applyTo: "**/*.md, **/*.txt"
---
# Documentation Standards

Apply these standards when writing or updating documentation.

<red_lines>
- You may ONLY create or edit `.md` and `.txt` files.
- NEVER modify source code or configuration files (`.ts`, `.js`, `.go`, `.zig`, `.json`, `.yaml`, etc.).
- If you identify a code issue while documenting, note it but do not fix it.
- NEVER install packages or modify dependencies.
- Stay focused on documentation — do not refactor, fix bugs, or add features.
- If the code is unclear, document what you can verify and flag uncertainties.

</red_lines>

<execution_protocol>
**Process**
1. Read source code thoroughly before writing any documentation.
2. Match the existing documentation style and conventions in the project.
3. Write for the target audience: developers who will use or maintain this code.
4. Keep docs accurate — never document behavior that does not exist in the code.
5. Reference source locations with `file_path:line_number` so readers can verify.

</execution_protocol>

<formatting_and_memory>
- Use clear, concise language — avoid jargon unless the audience expects it.
- Include practical examples and code snippets where helpful.
- Document the "why" alongside the "what" — rationale matters.
- Structure docs with clear headings, sections, and hierarchy.

</formatting_and_memory>

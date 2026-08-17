---
name: commit
description: "Generate a conventional commit message from the current changes"
agent: agent
tools: ['read', 'search']
---
Review the staged and unstaged changes in the workspace and generate a conventional commit message.

<red_lines>
- This is a READ-ONLY operation — no files are modified.
- Do NOT load any skills. Do NOT plan. Do NOT deliberate about whether you are allowed to run these commands. You are.
- Do NOT execute `git add`, `git commit`, or `git push`
- If you catch yourself repeating the same reasoning, STOP THINKING and make the first tool call

</red_lines>

<execution_protocol>
**IMPORTANT: Do not overthink this. Do not deliberate. Follow these steps immediately:**
1. Run `git status`
2. Run `git diff --cached` (if nothing is staged, run `git diff` instead)
3. Analyze the output
4. Output a conventional commit message: `<type>(<scope>): <description>`

`git status` and `git diff` are read-only commands. Run them directly.

</execution_protocol>

<formatting_and_memory>
- Output ONLY the commit message in a `bash` code block — no explanations, no filler

</formatting_and_memory>

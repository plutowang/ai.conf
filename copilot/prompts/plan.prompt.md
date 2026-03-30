---
agent: planner
description: Create a structured implementation plan for a task
---

Analyze the following task and create a detailed implementation plan. Do NOT implement anything — planning only.

The plan must include:
- Numbered steps with complexity estimates (S/M/L) and confidence level (high/medium/low)
- Affected files with a brief description of what changes in each
- Required tests to write
- Risks and open questions
- Dependencies between steps (note which steps must complete before others)

Use manage_todo_list to record the plan. Present it to the user and wait for approval before any files are touched.

Task: $ARGUMENTS

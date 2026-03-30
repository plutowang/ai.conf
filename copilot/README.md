# VSCode Copilot Configuration

User-level configuration for VSCode Copilot agents, prompts, and skills.

## Directory Structure

```
copilot/
├── setup-links.sh                # Symlink setup script
├── copilot-instructions.md       # Global always-on instructions
├── agents/                       # Custom agents
│   ├── architect.agent.md
│   ├── builder.agent.md
│   ├── code-reviewer.agent.md
│   ├── debug.agent.md
│   ├── docs.agent.md
│   ├── explore.agent.md
│   ├── planner.agent.md
│   ├── refactor.agent.md
│   ├── security-reviewer.agent.md
│   └── build-error-resolver.agent.md
├── instructions/                 # File-based always-on instructions
│   ├── code-standards.instructions.md
│   ├── development-workflow.instructions.md
│   ├── error-recovery.instructions.md
│   ├── git-workflow.instructions.md
│   ├── performance.instructions.md
│   └── testing.instructions.md
├── prompts/                      # Slash commands (manual)
│   ├── build-fix.prompt.md
│   ├── checkpoint.prompt.md
│   ├── commit.prompt.md
│   ├── continue.prompt.md
│   ├── deps.prompt.md

│   ├── plan.prompt.md
│   ├── refactor.prompt.md
│   ├── review.prompt.md
│   ├── security.prompt.md
│   ├── tdd.prompt.md
│   └── verify.prompt.md
├── skills/                       # Agent skills
│   ├── code-critic/SKILL.md
│   ├── code-review/
│   │   ├── SKILL.md
│   │   └── run-checks.sh
│   ├── git/SKILL.md
│   └── privacy-guard/SKILL.md
└── .vscode/
    └── mcp.json.example          # MCP server config template
```

## Installation

### Option 1: Setup Script (recommended)

Run the setup script to create symlinks in `~/.copilot/`:

```bash
./setup-links.sh

# Dry-run to preview changes:
./setup-links.sh --dry-run

# Force backup and replace existing files:
./setup-links.sh --force
```

This creates the following symlinks:
- `~/.copilot/agents/` -> `~/path/to/ai.conf/copilot/agents/`
- `~/.copilot/instructions/` -> `~/path/to/ai.conf/copilot/instructions/`
- `~/.copilot/prompts/` -> `~/path/to/ai.conf/copilot/prompts/`
- `~/.copilot/skills/` -> `~/path/to/ai.conf/copilot/skills/`
- `~/.copilot/copilot-instructions.md` -> `~/path/to/ai.conf/copilot/copilot-instructions.md`

### Option 2: Manual Symlink

```bash
mkdir -p ~/.copilot
ln -s ~/path/to/ai.conf/copilot/agents ~/.copilot/agents
ln -s ~/path/to/ai.conf/copilot/instructions ~/.copilot/instructions
ln -s ~/path/to/ai.conf/copilot/prompts ~/.copilot/prompts
ln -s ~/path/to/ai.conf/copilot/skills ~/.copilot/skills
ln -s ~/path/to/ai.conf/copilot/copilot-instructions.md ~/.copilot/copilot-instructions.md
```

### Option 3: VSCode Profile

Copy the contents into your VSCode profile settings folder:
- macOS: `~/Library/Application Support/Code/User/`
- Linux: `~/.config/Code/User/`
- Windows: `%APPDATA%\Code\User\`

## Quick Start

1. Run `./setup-links.sh` to create symlinks
2. Restart VSCode
3. Open Copilot Chat
4. Try a prompt like `/plan` or `/review`
5. Select a custom agent from the agent picker dropdown

## Prompts Reference

Prompts appear as slash commands in VSCode Copilot Chat:

| Prompt      | Description                              |
| ----------- | ---------------------------------------- |
| `/build-fix`  | Fix build errors                         |
| `/checkpoint` | Save session progress                    |
| `/commit`     | Generate a conventional commit message   |
| `/continue`   | Resume from checkpoint                   |
| `/deps`       | Audit dependencies                       |

| `/plan`       | Create an implementation plan            |
| `/refactor`   | Guided refactoring                       |
| `/review`     | Review code changes                      |
| `/security`   | Security audit                           |
| `/tdd`        | Test-driven development workflow         |
| `/verify`     | Run verification suite                   |

## Custom Agents

Custom agents appear in the agent picker dropdown:

| Agent                 | Purpose                                       |
| -------------------- | --------------------------------------------- |
| architect            | System design and architecture decisions       |
| builder              | Implementation from plans                     |
| build-error-resolver | Build/compile error diagnosis and fix         |
| code-reviewer        | Code quality, correctness, and maintainability |
| debug                | Problem diagnosis and root cause analysis      |
| docs                 | Documentation generation and maintenance      |
| explore              | Codebase search and web research              |
| planner              | Structured planning and task decomposition     |
| refactor             | Guided refactoring with behavior preservation  |
| security-reviewer    | Security audits and vulnerability detection    |

## Agent Tools Reference

Available tools for custom agents, specified in the agent definition YAML frontmatter as `tools: [...]`.

### File & Code Operations

| Tool                     | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `search`                 | Search files by name or content                  |
| `read`                   | Read file contents                               |
| `apply_patch`            | Apply code diffs/patches to files                |
| `create_file`            | Create new files                                 |
| `create_directory`        | Create new directories                           |
| `insert_edit_into_file`  | Insert or edit code in files                     |
| `list_dir`               | List directory contents                          |
| `file_search`            | Glob-based file search                           |
| `grep_search`            | Regex or text search in files                    |
| `semantic_search`        | Semantic code/documentation search              |

### Terminal & Git

| Tool                     | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `run_in_terminal`        | Run shell commands in a persistent terminal      |
| `get_terminal_output`    | Get output from a terminal command               |
| `await_terminal`         | Wait for a background terminal command          |
| `kill_terminal`          | Kill a background terminal                        |
| `create_and_run_task`    | Create and run VS Code tasks                     |
| `get_changed_files`      | List changed files in git                        |
| `get_search_view_results`| Get search view results                          |

### Error & Test

| Tool                     | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `get_errors`             | Get compile/lint errors                          |
| `test_failure`           | Get test failure info                            |

### Memory & Planning

| Tool                     | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `memory`                 | Persistent memory system (user/session/repo)    |
| `manage_todo_list`       | Structured todo list for planning                |

### VS Code API & Extension

| Tool                           | Description                                   |
| ------------------------------ | --------------------------------------------- |
| `get_vscode_api`               | Query VS Code API documentation               |
| `vscode_searchExtensions_internal` | Search VS Code extensions                 |
| `install_extension`            | Install a VS Code extension                   |
| `run_vscode_command`           | Run a VS Code command                         |

### Symbol & Refactoring

| Tool                   | Description                                      |
| ---------------------- | ------------------------------------------------ |
| `vscode_listCodeUsages` | Find symbol usages                             |
| `vscode_renameSymbol`  | Rename symbols across the workspace              |

### Notebook Operations

| Tool                         | Description                              |
| ---------------------------- | ---------------------------------------- |
| `create_new_jupyter_notebook` | Create a new Jupyter notebook            |
| `edit_notebook_file`         | Edit notebook cells                     |
| `copilot_getNotebookSummary` | Get notebook cell summaries             |
| `run_notebook_cell`          | Execute notebook cells                  |

### Web & Visualization

| Tool                  | Description                                      |
| --------------------- | ------------------------------------------------ |
| `fetch_webpage`       | Fetch webpage content                            |
| `open_browser_page`   | Open a browser page                             |
| `renderMermaidDiagram`| Render Mermaid diagrams                           |

### Other

| Tool                        | Description                              |
| --------------------------- | ---------------------------------------- |
| `terminal_last_command`     | Get last terminal command               |
| `terminal_selection`        | Get current terminal selection           |
| `get_project_setup_info`    | Get project setup info                   |
| `create_new_workspace`       | Scaffold a new project/workspace         |

## MCP Servers

1. Copy `.vscode/mcp.json.example` to `.vscode/mcp.json`
2. Set your API keys as environment variables (e.g., `CONTEXT7_API_KEY`)
3. VSCode should auto-detect MCP servers on restart

## Skill Loading

Skills are loaded via slash commands:

| Skill            | Description                          |
| ---------------- | ------------------------------------ |
| `/code-critic`     | Code critique and review             |
| `/code-review`    | Full code review                     |
| `/git`            | Git operations                       |
| `/privacy-guard`  | Privacy-sensitive data handling     |

## Known Limitations

1. **Built-in agents cannot be replaced or disabled**: Custom agents are additive only. The built-in Plan, Agent, and other agents remain available alongside custom ones.
2. **No tool-level enforcement**: The explore agent is a convention, not a hard constraint.
3. **No temperature or steps control**: Model parameters are global, not per-agent.
4. **`$ARGUMENTS` in prompts**: Works in VSCode, but behavior may differ from opencode.

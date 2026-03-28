# Migration Guide: Opencode → VSCode Copilot

This guide maps opencode configuration concepts to their VSCode Copilot equivalents, and documents what changed during the migration.

## Concept Mapping

| opencode | VSCode Copilot | Notes |
|---|---|---|
| `AGENTS.md` | `.github/copilot-instructions.md` | Global always-on instructions |
| `instructions/*.md` | `.github/instructions/*.instructions.md` | File-based always-on instructions |
| `commands/*.md` | `.github/prompts/*.prompt.md` | Slash commands (manual invocation) |
| `agents/*.md` | `.github/agents/*.agent.md` | Custom agents |
| `skills/global/*/SKILL.md` | `.github/skills/*/SKILL.md` | Agent skills |
| `opencode.json` → `agent.*.model` | Agent frontmatter `model:` | Per-agent model selection |
| `opencode.json` → `mcp` | `.vscode/mcp.json` | MCP server configuration |
| `opencode.json` → `default_agent: plan` | VSCode Chat default agent | Set in VSCode UI |
| `opencode.json` → `lsp` | VSCode native LSP | Configured in VSCode settings |
| `opencode.json` → `compaction` | VSCode context management | Built-in |

## File Structure

```
copilot/
├── .github/
│   ├── copilot-instructions.md     # Always-on global instructions
│   ├── instructions/               # File-based always-on instructions
│   │   ├── agent-constraints.instructions.md
│   │   ├── api-design.instructions.md
│   │   ├── code-standards.instructions.md
│   │   ├── development-workflow.instructions.md
│   │   ├── error-recovery.instructions.md
│   │   ├── git-workflow.instructions.md
│   │   ├── performance.instructions.md
│   │   └── testing.instructions.md
│   ├── prompts/                    # Slash commands (manual)
│   │   ├── commit.prompt.md
│   │   ├── plan.prompt.md
│   │   ├── review.prompt.md
│   │   ├── tdd.prompt.md
│   │   ├── security.prompt.md
│   │   ├── verify.prompt.md
│   │   ├── refactor.prompt.md
│   │   ├── checkpoint.prompt.md
│   │   ├── continue.prompt.md
│   │   ├── deps.prompt.md
│   │   ├── evolve.prompt.md
│   │   ├── learn.prompt.md
│   │   └── build-fix.prompt.md
│   ├── agents/                     # Custom agents
│   │   ├── architect.agent.md
│   │   ├── explore.agent.md
│   │   ├── code-reviewer.agent.md
│   │   ├── debug.agent.md
│   │   ├── docs.agent.md
│   │   ├── build-error-resolver.agent.md
│   │   ├── refactor.agent.md
│   │   ├── security-reviewer.agent.md
│   │   └── evolver.agent.md
│   └── skills/                    # Agent skills
│       ├── code-critic/SKILL.md
│       ├── code-review/
│       │   ├── SKILL.md
│       │   └── run-checks.sh
│       ├── git/SKILL.md
│       ├── nx-monorepo/SKILL.md
│       ├── privacy-guard/SKILL.md
│       ├── tailwind-v4/SKILL.md
│       └── workflow-env/SKILL.md
├── .vscode/
│   └── mcp.json.example           # MCP server config template
└── MIGRATION.md                   # This file
```

## What Was Dropped

### opencode-Specific Concepts

| Dropped | Reason |
|---|---|
| `output-formatting.md` | Workaround for opencode TUI code block rendering. VSCode Copilot has no such issue. |
| `opencode.json` → `compaction` | VSCode has built-in context management. No equivalent setting needed. |
| `opencode.json` → `watcher` | File watching patterns differ. VSCode handles this via native settings. |
| `opencode.json` → `plugin` | VSCode has no plugin system equivalent in the config format. |
| `opencode.json` → `share` | No equivalent in VSCode Copilot. |
| `opencode.json` → `autoupdate` | No equivalent in VSCode Copilot. |
| `opencode.json` → `lsp` | LSP is configured natively in VSCode settings, not in Copilot config. |
| Theme files | VSCode themes are configured separately via VSCode settings. |
| `evolver` agent's `opencode/retrospective.md` reference | This is an opencode-specific file. Users should adapt the path to their own retrospective system. |

### Tool-Level Enforcement

opencode enforces tool access at the runtime level (explore is the SOLE search agent, build has read, others have nothing). VSCode Copilot has **no equivalent runtime enforcement** — the `explore` agent is a convention, not a hard constraint.

**What to do**: The behavioral guidelines in `agent-constraints.instructions.md` describe the intended pattern. VSCode Copilot will not prevent an agent from using any tool.

### Temperature and Steps

opencode agents specify `temperature` and `steps`. VSCode Copilot agents have **no equivalent frontmatter fields**. Model parameters are controlled by VSCode settings, not per-agent.

## Agent Model Mapping

| opencode model | opencode env var | VSCode Copilot model |
|---|---|---|
| PRO | `{env:OPENCODE_MODEL_PRO}` | Claude Opus 4.5 |
| FLASH | `{env:OPENCODE_MODEL_FLASH}` | Claude Sonnet 4 |
| LITE | `{env:OPENCODE_MODEL_LITE}` | Claude Haiku |

## Installation

### Option 1: Symlink (recommended for dotfiles repos)

```bash
# In your project root
ln -s ~/path/to/ai.conf/copilot/.github .
ln -s ~/path/to/ai.conf/copilot/.vscode .
```

### Option 2: Copy

```bash
# In your project root
cp -r ~/path/to/ai.conf/copilot/.github .
cp -r ~/path/to/ai.conf/copilot/.vscode .
```

### Option 3: VSCode Profile (user-level)

Copy the `.github/` and `.vscode/` directories into your VSCode profile's settings folder:

- macOS: `~/Library/Application Support/Code/User/`
- Linux: `~/.config/Code/User/`
- Windows: `%APPDATA%\Code\User\`

### MCP Servers

1. Copy `.vscode/mcp.json.example` to `.vscode/mcp.json`
2. Set your `CONTEXT7_API_KEY` environment variable if using context7
3. VSCode should auto-detect the MCP servers

## Prompt File Usage

After installation, prompts appear as slash commands in VSCode Copilot Chat:

| Prompt | Usage |
|---|---|
| `/commit` | Generate a conventional commit message |
| `/plan` | Create an implementation plan |
| `/review` | Review code changes |
| `/tdd` | Test-driven development workflow |
| `/security` | Security audit |
| `/verify` | Run verification suite |
| `/refactor` | Guided refactoring |
| `/checkpoint` | Save session progress |
| `/continue` | Resume from checkpoint |
| `/deps` | Audit dependencies |
| `/evolve` | Architectural review |
| `/learn` | Log a learning point |
| `/build-fix` | Fix build errors |

## Custom Agent Usage

Custom agents appear in the agent picker dropdown in VSCode Copilot Chat:

- **Agent** (built-in): General implementation
- **Plan** (built-in): Planning
- **Ask** (built-in): Q&A
- **explore** (custom): Codebase search
- **architect** (custom): System design
- **code-reviewer** (custom): Code review
- **debug** (custom): Diagnosis
- **docs** (custom): Documentation
- **build-error-resolver** (custom): Build fixes
- **refactor** (custom): Refactoring
- **security-reviewer** (custom): Security audits
- **evolver** (custom): System evolution

## Known Gaps

1. **No tool-level enforcement**: The explore agent is a convention, not a hard constraint.
2. **No temperature control**: Model parameters are global, not per-agent.
3. **No compaction settings**: VSCode handles context automatically.
4. **No global permission system**: VSCode handles tool permissions via its own settings.
5. **`$ARGUMENTS` in prompts**: Works in VSCode, but behavior may differ slightly from opencode.

## Skill Loading

Skills are loaded differently in VSCode Copilot vs opencode:

| opencode | VSCode Copilot |
|---|---|
| `skill: load <name>` (tool call) | `/<skill-name>` (slash command) |
| Skills auto-load based on context | Skills must be invoked via `/` or manually |

The always-on instructions (`*.instructions.md`) provide behavioral guidance without requiring explicit skill loading.

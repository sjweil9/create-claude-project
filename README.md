# create-claude-project

Scaffolds a new project with a minimal reproducible baseline of AI-assisted
engineering standards.

## Install

```sh
git clone <this-repo> && cd create-claude-project
./install.sh
```

`install.sh` symlinks `bin/create-claude-project` into `~/.local/bin` (or
`/usr/local/bin`), tells you if that directory needs adding to your PATH, and
reports on required dependencies. Everything else is resolved at runtime: the
command finds a node >= 20 via nvm if your default node is older, and installs
the `@fission-ai/openspec` CLI globally if missing.

## Usage

```sh
create-claude-project <react|rails> <project-name> [--public] [--no-github]
```

Creates `./<project-name>` in the current directory. Then:

```sh
cd <project-name>
claude
```

The first `claude` session detects the uninitialized project and runs the
`project-interview` skill: it interviews you about goals and stack, authors
the `docs/` knowledge base, fills the OpenSpec context, and lands it all via
PR. From then on every change follows the cycle:

```
/opsx:explore → /opsx:propose → approve → worktree + /opsx:apply
             → review (code-reviewer/security-reviewer) → PR → owner merges → /opsx:archive
```

## What gets generated

| Layer | Mechanism |
|-------|-----------|
| Lean CLAUDE.md | Orchestrator role, agent routing table, workflow rules; detail lives in `docs/` and agent files |
| Specialist agents | `.claude/agents/` — planner, architect, code-reviewer, security-reviewer, qa, devops, ui-designer, refactor-cleaner + type-specific implementers (react: frontend, state; rails: backend, frontend, database-reviewer). Each has scope, guidelines, and explicit boundaries/handoffs. |
| OpenSpec | `openspec init --tools claude` → `/opsx:*` commands + skills; spec-driven change workflow |
| No direct work on main | Three independent layers: (1) GitHub branch protection (PRs required, no force pushes), (2) committed git hooks (`pre-commit`, `pre-push` block main), (3) Claude hooks — `bash-guard.sh` blocks push/commit/merge to main and `--no-verify`; `file-guard.sh` blocks file edits in any checkout on main, forcing worktrees |
| Worktree per change | `git worktree add .worktrees/<change-id> -b change/<change-id>`; parallel subagents use Agent-tool worktree isolation |
| Quality gates | Stop hook: session cannot end with failing lint/typecheck (rubocop for rails); PostToolUse hook: any `git merge`/`git pull` triggers full lint+build+test. Both auto-detect project type and no-op until the app is scaffolded. |
| First-run interview | `.claude/skills/project-interview/` — triggered by missing `docs/overview.md` |

## Requirements

- git, python3 (for the generated Claude hooks)
- `gh` authenticated (`gh auth login`) for GitHub repo creation; without it,
  use `--no-github` and push manually later
- node >= 20 on PATH or via nvm (found automatically)
- `@fission-ai/openspec` (auto-installed globally if missing)

Note: branch protection on **private** repos requires a paid GitHub plan. If
protection fails, the local guards still block direct pushes; re-run
`scripts/protect-main` inside the project after upgrading, or use `--public`.

## Editing the baseline

Templates live in `templates/`:
- `templates/shared/` — hooks, settings, docs scaffold, interview skill, shared agents
- `templates/react/`, `templates/rails/` — CLAUDE.md, gitignore, type-specific agents

`{{PROJECT_NAME}}` and `{{PROJECT_TYPE}}` are substituted at generation time.
Type-specific files override shared ones when both exist at the same path.

# create-claude-project

Scaffolds a minimal reproducible baseline of AI-assisted engineering
standards — either as a brand-new project (`create-claude-project`) or added
onto an existing codebase (`add-claude-scaffolding`).

## Install

```sh
git clone <this-repo> && cd create-claude-project
./install.sh
```

`install.sh` symlinks both commands into `~/.local/bin` (or
`/usr/local/bin`), tells you if that directory needs adding to your PATH, and
reports on required dependencies. Everything else is resolved at runtime: the
command finds a node >= 20 via nvm if your default node is older, and installs
the `@fission-ai/openspec` CLI globally if missing.

## Usage

### New project

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
the project-specific `docs/` (overview, architecture, deployment, schema),
tailors the pre-populated standards docs (code-standards, testing,
ui-patterns), fills the OpenSpec context, and lands it all via PR.

### Existing project

```sh
cd <existing-project>   # repo root, clean working tree
add-claude-scaffolding [react|rails] [--no-github]
```

Adds the same baseline to the project already in the current directory. The
type is auto-detected from `Gemfile`/`package.json` when omitted. Nothing is
overwritten: conflicting files are skipped and reported, `.gitignore` gains
only the missing entries, and a pre-existing `CLAUDE.md` gets the scaffold
content appended under a marker for the first session to reconcile.
Everything is committed on a `change/claude-scaffolding` branch — review it,
land it (PR, or a local fast-forward merge if there's no remote), then run
`claude`.

Because the codebase already answers most questions, the first session runs
`project-onboarding` instead of the greenfield interview: it investigates the
repo (stack, structure, schema, tests, CI), asks you to **confirm its
inferences** plus the things code can't reveal (goals, users, priorities),
and then authors the same `docs/` knowledge base — documenting what the
project actually does, with divergences from the baseline recorded as
candidate improvements rather than silently "fixed".

From then on every change follows the cycle:

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
| First-run bootstrap | Triggered by missing `docs/overview.md`: `.claude/skills/project-interview/` (new projects) or `.claude/skills/project-onboarding/` (existing codebases — infers from code, confirms, then documents) |
| Subagent models | Per-agent `model` frontmatter: `fable` for the judgment-heavy agents (planner, architect, code-reviewer, security-reviewer), `opus` for implementers and the rest. The orchestrating thread runs whatever model the session uses. |

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
- `templates/shared/` — hooks, settings, docs scaffold (pre-populated
  ui-patterns baseline), shared agents
- `templates/react/`, `templates/rails/` — CLAUDE.md, gitignore, type-specific
  agents, pre-populated code-standards/testing baselines
- `templates/create/` — greenfield-only extras (project-interview skill)
- `templates/add/` — existing-codebase-only extras (project-onboarding skill)

`{{PROJECT_NAME}}`, `{{PROJECT_TYPE}}`, and `{{BOOTSTRAP_SKILL}}` are
substituted at generation time. In create mode, type-specific files override
shared ones at the same path; in add mode, files already present in the
project always win and are reported as skipped.

# create-claude-project

Scaffolds a minimal reproducible baseline of AI-assisted engineering
standards — either as a brand-new project (`create-claude-project`, which
also generates a real Rails or React application) or added onto an existing
codebase (`add-claude-scaffolding`).

## Install

```sh
git clone <this-repo> && cd create-claude-project
./install.sh
```

`install.sh` symlinks both commands into `~/.local/bin` (or
`/usr/local/bin`), tells you if that directory needs adding to your PATH, and
reports on required dependencies. Everything else is resolved at runtime: the
command finds a node >= 22 via nvm if your default node is older, and installs
the `@fission-ai/openspec` CLI globally if missing.

## Usage

### New project

```sh
create-claude-project <react|rails|react-rails> <project-name> [options] [-- <rails new args>]
```

Creates `./<project-name>` in the current directory: a real application plus
the Claude baseline, as a **local-only git repo by default** — no remote is
created. Pass `--github` to also create a GitHub repo (private unless
`--public`), push main, and enable branch protection.

What gets generated per type:

- **rails** — `rails new` using whatever ruby/rails is active on your PATH
  (rbenv/rvm/asdf respected), defaulting to `--database=postgresql
  --css=tailwind` (tailwindcss-rails, standalone binary — no node), plus
  **Devise** with Tailwind-styled views. Development is **Dockerized**:
  `docker-compose.yml` runs the app with PostgreSQL 17 and Redis 7 on a
  `<name>_dev` network, and the generated `scripts/docker-setup`
  (idempotent) builds the dev image and runs bundle install, tailwind and
  devise installers (mailer URL options + layout flash messages applied,
  initializer rubocop-autocorrected), and `db:prepare` — **entirely in
  containers**. Nothing depends on host-installed PostgreSQL, Redis, or gem
  native builds; the host only needs ruby/rails (to generate) and Docker.
  If Docker isn't running at create time, the files still land and you run
  `scripts/docker-setup` later. Everything after `--` is passed straight to
  `rails new` — your own `--database`/`--css`/`--api` flags replace the
  defaults. `--skip-devise` skips Devise (model generation is left for the
  project interview); `--skip-docker` reverts to the host-toolchain flow
  (needs bundler + reachable PostgreSQL).
- **react** — Vite (`react-ts` template), managed with **npm** on the
  regular node runtime, with the
  baseline stack installed and wired: **React Router v7** (`src/router.tsx`;
  pass `--tanstack` to use **TanStack Router** with typed, code-based routes
  instead), **TanStack Query** (`src/lib/queryClient.ts`), **Zustand**
  (`src/stores/`), **React Hook Form + Zod** (installed, with
  `@hookform/resolvers`), **Axios** client with request/response
  interceptors and a normalized error shape (`src/lib/api/client.ts`),
  **Tailwind v4**, and **Vitest + React Testing Library + MSW** (jsdom
  environment, `src/test/` setup, sample component test) plus **type-aware
  ESLint** (flat config, typescript-eslint `strictTypeChecked`,
  react-hooks/react-refresh plugins, `eslint-config-prettier`) and Prettier;
  tsconfig gets `noUncheckedIndexedAccess` on top of `strict`. `npm run
  lint`, `npm run typecheck` (`tsc -b`, with a `typecheck:watch` variant),
  `npm run test`, and `npm run build` are all green out of the box, and the
  stop/merge quality-gate hooks run the same lint + typecheck. Also **Dockerized**: a dev container
  (`docker compose up`, node_modules in a named volume) with a commented-in
  switch to join another compose project's network — point
  `VITE_API_PROXY_TARGET` at a Rails backend's `app` service and the dev
  server proxies `/api/*` there, no CORS setup needed.
- **react-rails** — a `./<name>/` folder (plain folder, not a repo) holding
  **two independent repos**, each with the full baseline:
  `<name>-api` (rails `--api` + PostgreSQL + Redis + a **sidekiq worker**
  compose service) and `<name>-client` (react, as above). Sign-up/login is
  **wired end to end and hand-rolled** (`has_secure_password` + bcrypt, no
  auth gem): by default an **httpOnly session cookie** with a CSRF-token
  flow (`GET /api/csrf` → `X-CSRF-Token` header); with `--devise`, the same
  cookie flow and endpoints backed by **Devise** (warden +
  `database_authenticatable` behind custom JSON controllers — Devise's own
  routes/views are skipped, and password reset/confirmation/lockout are a
  module away) instead of the hand-rolled model; with `--jwt`, a 15-minute
  **JWT access token kept in memory** plus a 30-day **rotating single-use
  refresh token** in an httpOnly cookie (reuse detection revokes the family;
  only SHA-256 digests are stored). Dockerized by default: the client's
  compose file joins the API's `<name>-api_dev` network and the Vite dev
  server proxies `/api/*` to `http://app:3000`, so the browser keeps a
  single origin and cookies flow without CORS. Anything after `--` still
  goes to `rails new`; `--skip-docker` runs both apps on the host
  toolchain; `--tanstack` applies to the client. Each app documents its
  half of the flow in `docs/auth.md`.

`--skip-app` skips application generation entirely and lays down only the
Claude baseline in an empty repo. Then:

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
             → adversarial review (code-reviewer/security-reviewer) + browser smoke test (qa)
             → land → owner merges → /opsx:archive
```

## Commit policy: two modes

The repo is always initialized locally; a GitHub remote only exists if you
opt in (`--github` on create, or a remote the existing project already has).
How a change lands is detected at runtime from `git remote`:

- **Remote configured (PR flow)** — Claude commits on `change/*` branches,
  pushes, and opens a PR; you merge. Main only moves via PRs.
- **Local-only (no remote)** — Claude **never runs `git commit`** (enforced
  by `bash-guard.sh`). It leaves the finished change uncommitted in its
  worktree and presents a summary; you review, commit, and merge. Adding a
  remote later automatically switches the project to the PR flow.

## What gets generated

| Layer | Mechanism |
|-------|-----------|
| Application (create mode) | rails: `rails new` with the active ruby/rails — PostgreSQL + Tailwind + Devise by default, `rails new` flags passed through after `--`. react: Vite react-ts + React Router, TanStack Query, Zustand, React Hook Form + Zod, Axios (interceptors), Tailwind v4, Vitest + RTL + MSW, Prettier. |
| Dockerized dev (create mode) | rails: `Dockerfile.dev` + compose (app/postgres/redis on a `<name>_dev` network) + idempotent `scripts/docker-setup`; all toolchain steps run in containers, and the quality-gate hooks route rubocop/tests through `docker compose run` automatically. react: dev container with node_modules volume, plus a documented switch to join a backend's compose network via the Vite `/api` proxy. `--skip-docker` opts out. |
| Lean CLAUDE.md | Orchestrator role, agent routing table, workflow rules; detail lives in `docs/` and agent files. Standing guardrails: ask for clarification instead of assuming; never assume data shapes/APIs without samples or a real endpoint (stop and ask); escalate after 2 failed attempts (stop, analyze, change approach); no task is complete without an adversarial code review. |
| Specialist agents | `.claude/agents/` — planner, architect, code-reviewer (adversarial: its job is to find reasons the change is NOT done), security-reviewer, qa, devops, ui-designer, refactor-cleaner + type-specific implementers (react: frontend, state; rails: backend, frontend, database-reviewer). Each has scope, guidelines, and explicit boundaries/handoffs. |
| Vendored skills | `.claude/skills/` — Anthropic's `frontend-design` (loaded by frontend/ui-designer agents before significant UI work) and `webapp-testing` (loaded by qa to run headless-Playwright browser smoke tests, required for every UI-affecting change). |
| OpenSpec | `openspec init --tools claude` → `/opsx:*` commands + skills; spec-driven change workflow |
| No direct work on main | Three independent layers: (1) GitHub branch protection (PRs required, no force pushes), (2) committed git hooks (`pre-commit`, `pre-push` block main), (3) Claude hooks — `bash-guard.sh` blocks push/commit/merge to main, `--no-verify`, and **any** `git commit` when the repo has no remote (local-only mode); `file-guard.sh` blocks file edits in any checkout on main, forcing worktrees |
| Worktree per change | `git worktree add .worktrees/<change-id> -b change/<change-id>`; parallel subagents use Agent-tool worktree isolation |
| Quality gates | Stop hook: session cannot end with failing lint/typecheck (rubocop for rails); PostToolUse hook: any `git merge`/`git pull` triggers full lint+build+test. Both auto-detect project type and no-op until the app is scaffolded. |
| First-run bootstrap | Triggered by missing `docs/overview.md`: `.claude/skills/project-interview/` (new projects) or `.claude/skills/project-onboarding/` (existing codebases — infers from code, confirms, then documents) |
| Subagent models | Per-agent `model` frontmatter: `fable` for the judgment-heavy agents (planner, architect, code-reviewer, security-reviewer), `opus` for implementers and the rest. The orchestrating thread runs whatever model the session uses. |

## Requirements

- git, python3 (for the generated Claude hooks)
- `gh` authenticated (`gh auth login`) — only needed with `--github` (or for
  branch protection in add mode when a remote exists)
- node >= 22 on PATH or via nvm (found automatically) — used for the openspec
  CLI and the react test toolchain (vitest's jsdom/undici need >= 22.11)
- `@fission-ai/openspec` (auto-installed globally if missing)
- for `react` (and `react-rails`) projects: nothing beyond node >= 22 + npm
  (above) — the scaffold, dependency installs, and package scripts all run
  through npm
- for `rails` (and `react-rails`) projects: `rails` installed for the active
  ruby (`gem install rails`) and Docker with the compose plugin — postgres,
  redis, and all gem builds live in containers, so no host database or
  bundler is needed. (With `--skip-docker`: bundler and a reachable
  PostgreSQL server on the host instead.)

Note: branch protection on **private** repos requires a paid GitHub plan. If
protection fails, the local guards still block direct pushes; re-run
`scripts/protect-main` inside the project after upgrading, or use `--public`.

## Editing the baseline

Templates live in `templates/`:
- `templates/shared/` — hooks, settings, docs scaffold (pre-populated
  ui-patterns baseline), shared agents, vendored skills (`frontend-design`,
  `webapp-testing` from [anthropics/skills](https://github.com/anthropics/skills))
- `templates/react/`, `templates/rails/` — CLAUDE.md, gitignore, type-specific
  agents, pre-populated code-standards/testing baselines
- `templates/react-app/` — the React application scaffold overlaid onto the
  fresh Vite app in create mode only (router, query client, axios
  interceptors, zustand store, tailwind entry, vitest/MSW test setup, dev
  container + compose file)
- `templates/rails-app/` — the Rails Dockerized-dev scaffold overlaid in
  create mode only (Dockerfile.dev, docker-compose.yml with postgres/redis,
  scripts/docker-setup, dev-environment doc)
- `templates/react-app-tanstack/` — the `--tanstack` variant of the react
  scaffold's router/entry/layout (TanStack Router, code-based routes)
- `templates/react-rails/` — the react-rails auth wiring, overlaid on top of
  the per-app scaffolds: `api-common/` + `api-session/`/`api-jwt/`
  (controllers, models, migrations, routes, CORS) and `client-common/` +
  `client-session/`/`client-jwt/` (auth store, pages, API client;
  `client-tanstack/` swaps the router/pages for `--tanstack`), plus
  `api-docker/`/`client-docker/` compose overrides (worker service; shared
  network) and `parent-session/`/`parent-jwt/` (the parent README)
- `templates/create/` — greenfield-only extras (project-interview skill)
- `templates/add/` — existing-codebase-only extras (project-onboarding skill)

`{{PROJECT_NAME}}`, `{{PROJECT_TYPE}}`, `{{BOOTSTRAP_SKILL}}`,
`{{RAILS_MIGRATION_VERSION}}`, and `{{PEER_NAME}}` are substituted at
generation time. In create mode, type-specific files override
shared ones at the same path; in add mode, files already present in the
project always win and are reported as skipped.

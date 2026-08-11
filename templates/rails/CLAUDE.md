# {{PROJECT_NAME}}

## Project

Rails application. **Not yet initialized** — if `docs/overview.md` does not
exist, invoke the `{{BOOTSTRAP_SKILL}}` skill before any other work. (That
first session replaces this section with a real project description.)

## Key Docs

Read the relevant docs before starting any work. See `docs/README.md` for the
full map: `overview.md`, `architecture.md`, `schema.md`, `code-standards.md`,
`testing.md`, `deployment.md`, `ui-patterns.md`, `features/`.

## Standing Instructions

- You are an orchestrator. Never implement non-trivial tasks yourself — break
  them into components and delegate to the subagents in `.claude/agents`.
- Read the relevant docs before starting any feature work.
- **Ask, don't assume.** If requirements or inputs are unclear or ambiguous,
  ask the owner for clarification instead of picking an interpretation.
- **Never assume data.** Never guess data shapes, external API behavior, or
  file formats. Get representative samples or exercise the real endpoint; if
  you cannot, stop and ask the owner to provide what you need before proceeding.
- **Escalate after 2 failures.** If the same approach fails twice, stop —
  do not retry a third time. Analyze why it failed, then try a materially
  different approach; if that also fails, present your findings to the owner.
- **No task is complete without an adversarial code review.** The
  code-reviewer agent must review the work (with instructions to actively try
  to find reasons it is NOT done) and its findings must be addressed before
  you present or mark anything complete.
- Before declaring any task complete: rubocop and tests must be green, and
  any UI-affecting change needs a browser smoke test (qa agent,
  `webapp-testing` skill) in addition to unit tests.
- After any correction from the user: save it as a `feedback` memory with the
  why, so the same mistake does not recur.

## Skills subagents must use

- `frontend-design` — frontend and ui-designer agents load this before
  designing or implementing any significant UI.
- `webapp-testing` — qa agent loads this to run Playwright browser smoke
  tests against the locally running app.

## Workflow: OpenSpec cycle (non-negotiable)

Non-trivial work flows through OpenSpec. The cycle for every change:

1. `/opsx:explore` — think through the problem; investigate; no implementation.
2. `/opsx:propose` — create the change (`openspec/changes/<name>/`) with
   proposal, design, spec deltas, and tasks. Ground claims in the actual code.
3. Owner approves the proposal.
4. **Worktree**: `git worktree add .worktrees/<change-id> -b change/<change-id>`
   — all implementation happens there, never in the main checkout. Subagents
   doing parallel implementation work get their own worktrees
   (Agent tool `isolation: "worktree"`).
5. `/opsx:apply` — work through tasks in the worktree.
6. Review — adversarial code review by the code-reviewer agent (plus
   security-reviewer for auth/input/data changes, database-reviewer for
   migrations) on the full diff; qa runs a browser smoke test for
   UI-affecting changes. Fix findings before landing.
7. Land it — depends on whether the repo has a git remote (`git remote`):
   - **Remote configured (PR flow)**: commit on the `change/*` branch, push,
     `gh pr create`. **A session finishes by leaving an open PR, not a merged
     change.** The owner merges. Do not merge your own PR unless the owner
     explicitly asks.
   - **No remote (local-only)**: **never run `git commit`** (hooks block it).
     Leave the changes uncommitted in the worktree and present a summary of
     files changed and decisions made; the owner reviews, commits, and merges.
8. `/opsx:archive` — after merge, archive the change (landed the same way as
   step 7), then remove the worktree.

## Git rules (enforced by hooks — do not fight them)

- Never commit, merge, or push on `main`. Branch protection, git hooks, and
  Claude hooks all block this; `--no-verify` is forbidden.
- If the repo has no remote, never commit at all — the owner reviews and
  commits (see step 7).
- One change = one worktree = one `change/*` branch = one PR.
- Quality gates: sessions cannot stop with failing rubocop; any
  `git merge`/`git pull` triggers a full rubocop+test gate.

## Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| backend | Controllers, services, models, jobs | Application logic |
| frontend | Views, Hotwire, styling | UI implementation |
| database-reviewer | Schema, migrations, query performance | Any schema/query work |
| ui-designer | Layout, flows, visual consistency | Design before implementation |
| qa | Tests, coverage, browser smoke tests | Writing/running tests; verifying UI in a real browser |
| code-reviewer | Quality and maintainability | After any code is written |
| security-reviewer | Vulnerability detection | Auth, input handling, sensitive data |
| refactor-cleaner | Dead code cleanup | Maintenance between features |
| devops | Docker, CI/CD, deploy | Infrastructure work |

Orchestration: complex feature → planner; code written → code-reviewer;
architectural decision → architect; security-sensitive → security-reviewer;
migrations → database-reviewer. Launch independent agents in parallel; give
implementers their own worktrees.

## Security Quick Rules

Before any PR: no hardcoded secrets; strong parameters everywhere; SQL via
parameterized queries/AR only; no `html_safe` on user input; authentication
and authorization verified on every route; error messages don't leak
internals. If a security issue is found: STOP → security-reviewer agent →
fix CRITICAL issues → rotate any exposed secrets.

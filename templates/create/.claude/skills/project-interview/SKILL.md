---
name: project-interview
description: First-session bootstrap. Use IMMEDIATELY when docs/overview.md does not exist - this project has been scaffolded but not yet initialized. Interviews the owner about goals and stack, then authors the docs/ knowledge base, fills openspec/config.yaml context, and updates CLAUDE.md - landed via PR (or presented uncommitted for owner review when the repo has no remote).
---

# Project Interview

This repo was scaffolded by `create-claude-project` as a **{{PROJECT_TYPE}}**
project named **{{PROJECT_NAME}}**, but carries no requirements yet. Your job:
interview the owner, then convert their answers into the durable documentation
that every future agent session will read.

## Ground rules

- Interview conversationally, in small batches (2-4 questions at a time, using
  AskUserQuestion where it fits). Do not dump one giant questionnaire.
- Push for concrete answers where they matter, but accept "you decide" — record
  the decision you make and mark it `(defaulted)` so it's revisitable.
- **All writes happen on a branch.** Before writing any file:
  `git switch -c change/project-init` (the hooks block edits on main).

## Step 1 — Interview

Cover these areas, adapting depth to the answers:

**Product** (both types)
- What is the app? Who uses it? What problem does it solve?
- Top 3 features for a first usable version; explicit non-goals.
- Solo project or collaborators? Expected scale (hobby / small team / production SaaS)?

**Stack — react projects**
- Build/framework: Vite SPA (default) or a meta-framework (Next/Remix)? SSR needed?
- Styling: Tailwind (default)? Component library or hand-rolled?
- State/data: TanStack Query + Zustand (default), or other?
- Backend: existing API to consume, new API to build separately, or none?
- Testing: Vitest + React Testing Library (default); Playwright e2e?
- Deploy target: Vercel/Netlify/static host/other?

**Stack — rails projects**
- Rails version and API-only vs full-stack with Hotwire (default: full-stack + Hotwire + Tailwind)?
- Database: PostgreSQL (default) or other? Background jobs needed (Sidekiq/SolidQueue)?
- Auth: Devise, Rails 8 built-in auth, or none?
- Testing: Minitest (default) or RSpec? Factory Bot? System tests?
- Deploy target: Kamal to a VPS, Heroku/Render, Docker, other?

**Quality bars** (both)
- Accessibility target (default: WCAG 2.1 AA), dark/light mode support?
- Anything unusually security-sensitive (payments, PII, multi-tenancy)?

## Step 2 — Author the documentation

On the `change/project-init` branch, write (see `docs/README.md` for the doc map):

1. Author `docs/overview.md`, `docs/architecture.md`, `docs/deployment.md`
   (+ `docs/schema.md` for rails). Record decisions **with their why**; mark
   defaulted decisions `(defaulted)`.
2. Review the pre-populated `docs/code-standards.md`, `docs/testing.md`, and
   `docs/ui-patterns.md` against the interview answers: fill in chosen
   versions, adjust anything the owner overrode (framework swaps, coverage
   bar, accessibility target), and record project-specific additions. Do not
   rewrite what still applies.
3. `openspec/config.yaml` — fill the `context:` block with a tight summary of
   stack, conventions, and domain (this is injected into every OpenSpec artifact).
4. `CLAUDE.md` — replace the "Project" placeholder section with a 3-5 line real
   description. Do not grow CLAUDE.md beyond that; detail belongs in docs/.
5. If any answer changes agent boundaries (e.g. no database), note it in the
   relevant `.claude/agents/*.md` file.

## Step 3 — Land it

1. How to land depends on whether the repo has a remote (`git remote`):
   - **Remote configured**: commit, push the branch, open a PR
     (`gh pr create`) summarizing the decisions made and any defaults taken.
     The owner merges.
   - **No remote (local-only)**: do NOT commit (hooks block it). Leave the
     changes uncommitted on the branch and present the same summary of
     decisions and files written; the owner reviews, commits, and merges.
2. Tell the owner the next step: after merging, the first real change is
   scaffolding the app itself — start with `/opsx:propose "scaffold the
   application"`, which flows through the standard cycle
   (propose → approve → worktree + `/opsx:apply` → review → PR → merge → `/opsx:archive`).

---
name: project-onboarding
description: First-session bootstrap for an existing codebase. Use IMMEDIATELY when docs/overview.md does not exist - Claude scaffolding was added to this pre-existing project but it has not been onboarded yet. Investigates the codebase, confirms inferences with the owner, then authors the docs/ knowledge base, fills openspec/config.yaml context, and reconciles CLAUDE.md - all landed via PR.
---

# Project Onboarding

Claude scaffolding was added to this **existing {{PROJECT_TYPE}}** project
(**{{PROJECT_NAME}}**) by `add-claude-scaffolding`. Unlike a greenfield
project, most facts are already in the code. Your job: **infer everything the
codebase can tell you, confirm it with the owner, and interview only for what
code cannot reveal** — then convert that into the durable documentation every
future agent session will read.

## Ground rules

- **Investigate before asking.** Never ask the owner something the repo
  already answers. Every question you do ask should either confirm an
  inference or cover something genuinely unknowable from code (goals, users,
  roadmap, quality bars).
- Present inferences as confirmations ("I see X — is that right?"), in small
  batches (AskUserQuestion works well). Accept corrections gracefully — the
  owner outranks the code's appearance.
- **Document reality, not the baseline.** Where this project diverges from the
  scaffold's pre-populated standards (different test framework, no Tailwind,
  fat controllers), the docs must record what the project actually does.
  List divergences the owner wants to fix as candidate improvements — do NOT
  refactor the codebase during onboarding.
- **All writes happen on a branch.** Before writing any file:
  `git switch -c change/project-init` (the hooks block edits on main).

## Step 1 — Investigate the codebase

Sweep the repo (use Explore/subagents for breadth) and build an inferred
picture of:

- **Stack & versions** — Gemfile.lock / package.json, framework and language
  versions, key libraries (auth, jobs, state management, styling, HTTP).
- **Structure & patterns** — directory layout, layering (where business logic
  actually lives), naming conventions, notable deviations from framework
  defaults.
- **Schema** (rails) — `db/schema.rb` / migrations: entities, relationships,
  indexes.
- **Testing** — framework(s) present, coverage tooling, how tests run, rough
  coverage reality (thorough / partial / absent).
- **Tooling & CI/CD** — linters and their configs, CI workflows, Dockerfiles,
  deploy configuration, environment/secrets handling.
- **Existing docs** — README, docs/, comments, an existing CLAUDE.md or
  AGENTS.md; treat them as claims to verify against the code, not facts.

## Step 2 — Confirm and fill the gaps

Interview the owner:

1. **Confirmations** — your inferred stack/architecture/schema/testing
   picture, batched, with anything surprising called out.
2. **Unknowables** — what the app is for, who uses it, top upcoming
   priorities, explicit non-goals, expected scale, anything unusually
   security-sensitive (payments, PII, multi-tenancy).
3. **Quality bars** — accessibility target (default WCAG 2.1 AA), dark/light
   mode, coverage expectations going forward; and which observed divergences
   from the pre-populated standards docs are intentional (keep, document why)
   vs. debt (record as candidate improvements).

## Step 3 — Author the documentation

On the `change/project-init` branch (see `docs/README.md` for the doc map):

1. Author `docs/overview.md`, `docs/architecture.md`, `docs/deployment.md`
   (+ `docs/schema.md` for rails) **grounded in the observed code**, folding
   in the owner's answers. Record decisions with their why; mark inferred
   facts the owner confirmed as normal decisions, and anything defaulted
   `(defaulted)`.
2. Reconcile the pre-populated `docs/code-standards.md`, `docs/testing.md`,
   and `docs/ui-patterns.md` with observed reality: fill in actual versions
   and tools, replace baseline claims the project contradicts, and add a
   short **Candidate improvements** section for divergences the owner wants
   fixed later (each becomes a future OpenSpec change, not onboarding work).
3. If the codebase has significant existing features, capture each as a brief
   spec in `docs/features/` — behavior as it exists, not as designed long ago.
4. `openspec/config.yaml` — fill the `context:` block with a tight summary of
   stack, conventions, and domain (this is injected into every OpenSpec
   artifact).
5. **Reconcile `CLAUDE.md`** — if `add-claude-scaffolding` appended the
   scaffold section below a marker comment to a pre-existing CLAUDE.md, merge
   the two into one coherent file: keep the project's real description and
   any project-specific instructions, keep the scaffold's orchestration/
   workflow/git rules, drop the marker. Otherwise just replace the "Project"
   placeholder section with a 3-5 line real description. Do not grow CLAUDE.md
   beyond that; detail belongs in docs/.
6. If anything observed changes agent boundaries (e.g. no database, different
   test layout), note it in the relevant `.claude/agents/*.md` file.

## Step 4 — Land it

1. Commit, push the branch, open a PR (`gh pr create`) summarizing what was
   inferred, what the owner corrected, and any defaults taken. The owner
   merges.
2. Tell the owner the next step: from now on every non-trivial change flows
   through the OpenSpec cycle
   (`/opsx:explore` → `/opsx:propose` → approve → worktree + `/opsx:apply`
   → review → PR → merge → `/opsx:archive`) — a good first change is the top
   item from the candidate-improvements list.

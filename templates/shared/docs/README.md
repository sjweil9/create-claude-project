# Project documentation

This directory is the durable knowledge base every agent session reads before
working. Project-specific documents start absent on purpose: the first
`claude` session in this repo runs the `{{BOOTSTRAP_SKILL}}` skill, which
authors them from an owner interview (grounded in the existing codebase, when
there is one). Generic standards docs ship pre-populated with the scaffold's
baseline; that first session reviews and tailors them.

Expected documents (kept current by every change):

| Document | Source | Contents |
|----------|--------|----------|
| `overview.md` | interview | Project goals, users, scope, non-goals |
| `architecture.md` | interview | Stack decisions, system structure, key patterns, ADRs |
| `code-standards.md` | pre-populated | Style, naming, linting, layer responsibilities |
| `testing.md` | pre-populated | Test frameworks, coverage expectations, principles |
| `deployment.md` | interview | Environments, deploy pipeline, secrets handling |
| `dev-environment.md` | pre-populated (new projects) or onboarding | How to run the app and its toolchain locally (scaffolded apps ship a Dockerized setup) |
| `ui-patterns.md` | pre-populated | UI/UX principles, theming, accessibility targets |
| `schema.md` | interview | Database schema and data-model notes (rails projects) |
| `auth.md` | pre-populated (react-rails pairs only) | How sign-up/login works in this half of the pair (session cookie or JWT + refresh token) |
| `features/` | ongoing | One spec per shipped feature (kept in sync via OpenSpec archive) |

Rules:
- Documents record **decisions and their why**, so future sessions inherit them
  instead of re-deriving or reverting them.
- When a rule is retired, record why it died, in place — do not silently delete.
- When behavior deliberately diverges from an earlier decision, mark it as
  acknowledged, not a silent regression.

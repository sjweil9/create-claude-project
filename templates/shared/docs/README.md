# Project documentation

This directory is the durable knowledge base every agent session reads before
working. It starts empty on purpose: the first `claude` session in this repo
runs the `project-interview` skill, which interviews the owner and authors
these documents from the answers.

Expected documents (authored by the interview, kept current by every change):

| Document | Contents |
|----------|----------|
| `overview.md` | Project goals, users, scope, non-goals |
| `architecture.md` | Stack decisions, system structure, key patterns, ADRs |
| `code-standards.md` | Style, naming, linting, conventions |
| `testing.md` | Test frameworks, coverage expectations, how to run |
| `deployment.md` | Environments, deploy pipeline, secrets handling |
| `ui-patterns.md` | UI/UX conventions, theming, accessibility targets |
| `schema.md` | Database schema and data-model notes (rails projects) |
| `features/` | One spec per shipped feature (kept in sync via OpenSpec archive) |

Rules:
- Documents record **decisions and their why**, so future sessions inherit them
  instead of re-deriving or reverting them.
- When a rule is retired, record why it died, in place — do not silently delete.
- When behavior deliberately diverges from an earlier decision, mark it as
  acknowledged, not a silent regression.

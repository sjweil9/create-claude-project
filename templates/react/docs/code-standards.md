# Code Standards

Baseline standards shipped with the scaffold. The project interview tailors
this doc; project-specific decisions get recorded here with their why.

## Language & Tooling

- **TypeScript everywhere**, `strict: true`. No `any` at boundaries — type
  every API response, prop, and store. Prefer discriminated unions over
  boolean flags for multi-state values.
- **ESLint + Prettier** enforced. Fix violations, don't disable rules; a
  disable comment needs an inline reason.
- `tsc -b` green is a gate of its own — the bundler and test runner do not
  typecheck.
- Start from the latest stable React and tooling; record chosen versions here
  once the app is scaffolded. Stay current: minor/patch upgrades eagerly,
  major upgrades deliberately.

## Components

- **Functional components and hooks only** — no class components.
- **Small and composable** — build complex UI from single-purpose components;
  extract shared UI once a third consumer exists, not before.
- **Presentational components stay dumb** — data fetching and business logic
  live in the data layer; components consume via hooks.
- Every data-driven view handles **loading, error, and empty** states.
- Stable `key`s in lists — never array index for reorderable lists.
- **Memoization**: let the React Compiler handle it where enabled; reach for
  manual `useMemo`/`useCallback`/`React.memo` only with a measured reason.
- **`useEffect` is a last resort** — not for data fetching (query layer does
  that), derived state (compute during render), or reacting to user events
  (event handlers do that). Effects are for synchronizing with external
  systems only.

## State & Data

- **One source of truth per piece of state**: server state lives in the query
  cache (TanStack Query by default), client state in stores (Zustand by
  default) — never duplicate one into the other.
- All HTTP goes through one API client layer (`src/lib/api/`) that normalizes
  errors, so components handle a single error shape.
- Cache invalidation is part of every mutation — name the queries a mutation
  invalidates in the same change that adds the mutation.
- Never store secrets in client code or localStorage.

## Structure & Naming

- **Group by feature**: `src/features/<feature>/` owns its components, hooks,
  queries/mutations, and types. Shared UI primitives live in
  `src/components/`, cross-cutting utilities and the API client in `src/lib/`.
- Components and their files are `PascalCase` (`UserCard.tsx`); hooks are
  `useCamelCase`; everything else `camelCase`. If the project adopts a
  different file-naming convention at the start, record it here and apply it
  consistently.
- No barrel-file sprawl: add an `index.ts` re-export only at a feature's
  public boundary.

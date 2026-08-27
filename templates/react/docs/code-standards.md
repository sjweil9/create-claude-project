# Code Standards

Baseline standards shipped with the scaffold. The project interview tailors
this doc; project-specific decisions get recorded here with their why.

## Language & Tooling

- **TypeScript everywhere**, `strict: true` plus `noUncheckedIndexedAccess`
  (so `arr[i]` is `T | undefined` — catches real bugs). **`any` is banned** —
  not just at boundaries: type every API response, prop, and store; when a
  shape is genuinely dynamic, use `unknown` and narrow it. A cast to `any`
  (or `as unknown as X`) needs an inline reason and should almost never
  survive review. Prefer discriminated unions over boolean flags for
  multi-state values.
- **Type-aware ESLint** (flat config + typescript-eslint
  `strictTypeChecked`) enforced — it catches what tsc can't express as
  errors: `no-floating-promises` (the single highest-value rule in async
  React code), `no-misused-promises`, unsafe `any` flow. It runs the TS
  program under the hood, so it's slower — editors may run only the fast
  rules, but `bun run lint` in the quality gates and CI always runs the full
  config. Fix violations, don't disable rules; a disable comment needs an
  inline reason.
- **Prettier** for formatting, with `eslint-config-prettier` silencing the
  conflicting lint rules. (An acceptable alternative if the project prefers:
  Biome for formatting + fast basic lint, keeping typescript-eslint's
  type-aware rules in CI — Biome's own type inference doesn't yet match
  typescript-eslint's depth.)
- `tsc -b` green is a gate of its own — the bundler and test runner do not
  typecheck. `bun run typecheck` in CI/gates; `bun run typecheck:watch`
  locally while developing.
- **Dates**: format and localize with the built-in `Intl` APIs; reach for
  **date-fns** for the comparison/manipulation functions `Intl` can't
  express (isBefore, differenceInDays, addBusinessDays, …). Never hand-roll
  date math, and don't add heavier date libraries.
- Start from the latest stable React and tooling; record chosen versions here
  once the app is scaffolded. Stay current: minor/patch upgrades eagerly,
  major upgrades deliberately.

## Components

- **Functional components and hooks only** — no class components.
- **Single responsibility** — each component has one job and one reason to
  change; when a component accumulates a second concern, split it into
  focused sub-components.
- **Composition over god components** — build complex UI by combining small,
  independent pieces; extract shared UI once a third consumer exists, not
  before.
- **Custom hooks for stateful logic** — extract reusable stateful logic into
  `use*` hooks outside the visual components, keeping both the logic and the
  components clean and independently testable.
- **Presentational components stay dumb** — data fetching and business logic
  live in the data layer; components consume via hooks.
- **Build on shadcn/ui as the component base** where possible — add
  primitives with `bunx shadcn@latest add <component>` and restyle via
  Tailwind/tokens rather than hand-rolling buttons, dialogs, dropdowns,
  forms, and tables from scratch. Hand-rolled primitives need a reason
  shadcn can't cover.
- Every data-driven view handles **loading, error, and empty** states.
- Stable `key`s in lists — never array index for reorderable lists.
- **Memoization**: let the React Compiler handle it where enabled; reach for
  manual `useMemo`/`useCallback`/`React.memo` only with a measured reason.
- **`useEffect` is a last resort** — not for data fetching (query layer does
  that), derived state (compute during render), or reacting to user events
  (event handlers do that). Effects are for synchronizing with external
  systems only.

## State & Data

- **One source of truth per piece of state, separated by kind**: local UI
  state stays inside the component that owns it; server data lives in the
  query cache (TanStack Query by default); global client/UI state goes in
  lightweight stores (Zustand by default) — never duplicate one into another.
- **Lift state up before reaching for a store**: when sibling components need
  the same state, move it to their closest common parent; promote it to a
  store only when prop drilling becomes genuinely unwieldy.
- All HTTP goes through one API client layer (`src/lib/api/`) that normalizes
  errors, so components handle a single error shape.
- **Debounce every input that triggers server work** — search-as-you-type
  queries, autosaves, filter changes. A keystroke must never map 1:1 to a
  network request; ~300ms is a sane default, and TanStack Query's query-key
  change on the debounced value handles cancellation of the stale request.
- **Cached state must not go stale silently.** Give every cache a deliberate
  TTL: the scaffold's query client defaults to `staleTime: 30s` (background
  refetch after that) — override per query with intent, not by accident, and
  apply the same discipline to any hand-rolled cache (store + timestamp).
- **Cache invalidation is part of every mutation** — name the queries a
  mutation invalidates (`queryClient.invalidateQueries`) in the same change
  that adds the mutation; a mutation with no invalidation list is a review
  flag.
- **Paginate index-style data by default** — any query or view returning
  multiple records is paginated (or cursor/infinite-scrolled) from day one,
  with the page size chosen server-side. Unbounded "fetch all rows" lists
  are a bug, not a starting point.
- Never store secrets in client code or localStorage.

## Structure & Naming

- **Group by feature, not by technical type**: `src/features/<feature>/`
  (auth, profile, dashboard, …) owns its components, hooks, queries/mutations,
  and types — no app-wide `components/`/`hooks/` dumping grounds. Shared UI
  primitives live in `src/components/`, cross-cutting utilities and the API
  client in `src/lib/`.
- **Colocate** tests, styles, and sub-components next to the feature file
  they belong to (`HomePage.tsx` + `HomePage.test.tsx` side by side).
- Components and their files are `PascalCase` (`UserCard.tsx`); hooks are
  `useCamelCase`; everything else `camelCase`. If the project adopts a
  different file-naming convention at the start, record it here and apply it
  consistently.
- No barrel-file sprawl: add an `index.ts` re-export only at a feature's
  public boundary.

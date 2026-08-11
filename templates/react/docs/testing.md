# Testing

Baseline standards shipped with the scaffold. The project interview tailors
this doc (framework swaps, coverage targets, whether e2e is configured).

## Stack (defaults)

- **Vitest** — test runner and coverage
- **React Testing Library** — component tests
- **MSW (Mock Service Worker)** — stub all network requests
- **Playwright** — e2e for critical user journeys, when the project opts in

## Test Types

- **Unit tests** — pure logic: utilities, data transforms, store logic
- **Component tests** — interactions and rendered behavior via Testing Library
- **e2e tests** — critical user journeys only; keep the suite small and fast

## Principles

- **Test behavior from the user's perspective** — query by role/label/text,
  not by test IDs or implementation details; asserting on internal state or
  mock call counts is a smell
- Tests must be **deterministic** — fake timers and dates where time matters;
  no real network; no order-dependent tests
- Never weaken assertions or delete tests to get green — surface the tradeoff
- Vitest does not typecheck — `tsc -b` green is a separate gate

## Browser Smoke Tests

- Every UI-affecting change gets a **browser smoke test** in addition to
  unit/component tests: the qa agent loads the `webapp-testing` skill and
  drives the running dev server with headless Playwright (screenshots, no
  console errors, primary interaction works)
- Smoke tests are a completion gate, not an optional extra; if one is
  impossible, the reason is reported explicitly
- Durable smoke flows graduate into the Playwright e2e suite

## External Interactions

- **All network requests must be stubbed** with MSW — never hit real APIs in
  tests
- **Never assume** external request/response formats without documentation
- If adequate documentation is not available, stop and ask for concrete
  examples before writing stubs

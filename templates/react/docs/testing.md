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

Pick the altitude by scope: **React Testing Library tests components** (one
component or a small tree, network stubbed with MSW); **Playwright tests
features** (a whole user journey — sign up, log in, complete the core flow —
against the running app). Don't write RTL tests that wire up half the app to
simulate a journey, and don't burn Playwright time on single-component
states RTL covers in milliseconds.

## Principles

- **Test what the user sees, not implementation details** — query by
  role/label/text, not by test IDs, component internals, or DOM structure;
  asserting on internal state, hook return values, or mock call counts is a
  smell. If a refactor that preserves behavior breaks the test, the test was
  wrong.
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

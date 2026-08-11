# Testing

Baseline standards shipped with the scaffold. The project interview tailors
this doc (framework swaps like RSpec, coverage targets, system tests).

## Stack (defaults)

- **Minitest** — test framework
- **Factory Bot** — test data generation
- **SimpleCov** — code coverage; target complete coverage of app code unless
  the interview sets a different bar
- **WebMock** — stub all external HTTP requests
- **n_plus_one_control / Bullet** — detect N+1 queries; violations fail tests

## Test Types

- **Unit tests** — validate individual Rails object behavior (models,
  presenters, services, jobs, lib adapters)
- **Integration tests** — validate features end-to-end as a whole

## Principles

- Tests must be **deterministic** — freeze time where time matters; no real
  network; no order-dependent tests
- Test behavior, not implementation — assert on outcomes (records, responses,
  rendered content), not on internal calls, wherever possible
- Never weaken assertions or delete tests to get green — surface the tradeoff

## Browser Smoke Tests

- Every UI-affecting change gets a **browser smoke test** in addition to
  unit/integration tests: the qa agent loads the `webapp-testing` skill and
  drives the running Rails server with headless Playwright (screenshots, no
  console errors, primary interaction works)
- Smoke tests are a completion gate, not an optional extra; if one is
  impossible, the reason is reported explicitly
- Durable smoke flows graduate into system tests (Capybara) so they run in CI

## External Interactions

- **All external requests must be stubbed** with WebMock
- **Never assume** external request/response formats without documentation
- If adequate documentation is not available, stop and ask for concrete
  examples before writing stubs

## Query Performance

- Use n_plus_one_control and/or Bullet to assert no N+1 queries
- Treat query performance violations as test failures

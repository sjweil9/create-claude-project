# Code Standards

Baseline standards shipped with the scaffold. The project interview tailors
this doc; project-specific decisions get recorded here with their why.

## Versions

- Manage Ruby with a version manager (rvm/rbenv/asdf); commit `.ruby-version`.
- Start from the latest stable Ruby and Rails; record the chosen versions here
  once the app is scaffolded.
- Stay current: take minor/patch upgrades eagerly; plan major upgrades
  deliberately, avoiding big-bang breaking changes.

## General Style

- **Short, concise methods** — break complex logic into small, single-purpose methods
- **Object-oriented Ruby** — objects own their data and communicate via
  messages; avoid imperative style
- **DRY and modular** — extract reusable components; avoid duplication
- **Minimal metaprogramming** — outside of Rails built-ins, keep code explicit
  and comprehensible
- **Rubocop** — enforce default rules; maintain the config and override default
  cops only on explicit instruction, recording the reason in the config

## Architecture by Layer

### Controllers
- Orchestration only: permit params, delegate to service objects/presenters,
  render via serializer or view
- No business logic in controllers

### Models
- Validations and self-update logic (callbacks, hooks for data changes)
- Models know how to maintain their own data integrity
- No presentation logic; no reaching out to external systems

### Service Objects / Presenters
- Business logic lives in service objects, invoked by controllers
- Presenters own display logic and data transformations for views

### Jobs
- Thin: a job schedules and retries; the work itself lives in a service object
  it delegates to

### lib/
- All external system interaction: API adapters, data translators/mappers
- The rest of the app consumes these through their interfaces and never talks
  to external systems directly

### Serializers
- Handle JSON/API response formatting

### Views
- Markup only: render data handed over by presenters/partials; no queries or
  business logic in templates

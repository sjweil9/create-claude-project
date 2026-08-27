# {{PROJECT_NAME}}

Full-stack pair scaffolded by `create-claude-project react-rails`:

- **`{{API_NAME}}/`** — Rails API (API-only, PostgreSQL, Redis, sidekiq
  worker; Dockerized dev)
- **`{{CLIENT_NAME}}/`** — React client (Vite + TypeScript, bun, Tailwind;
  Dockerized dev)

Each app is its **own git repository** with the full Claude engineering
baseline (agents, hooks, OpenSpec). Run `claude` inside each one to run its
project interview.

## Running (Docker, default)

```sh
# 1. API — one-time setup builds the image, installs gems, prepares the DB
cd {{API_NAME}}
scripts/docker-setup
docker compose up          # app + worker + postgres + redis on {{API_NAME}}_dev

# 2. Client — joins the API's compose network (start the API first)
cd ../{{CLIENT_NAME}}
docker compose up          # Vite dev server

open http://localhost:5173
```

The client's Vite dev server proxies `/api/*` to the API at `http://app:3000`
over the shared `{{API_NAME}}_dev` compose network, so the browser sees a
single origin.

Without Docker (`--skip-docker` at create time): run the API with
`bin/rails server` and the client with `bun run dev`; the proxy targets
`http://localhost:3000`.

## Auth: session cookie (default)

Sign-up/login is wired end to end with Rails' **encrypted, httpOnly session
cookie** — no auth gem, every moving part visible in the code:

- The cookie is httpOnly, so JavaScript can never read the credential.
- State-changing requests carry a **CSRF token** the client reads from
  `GET /api/csrf` and echoes in the `X-CSRF-Token` header; it rotates with
  the session on login/logout.
- `reset_session` on login prevents session fixation.

Endpoints: `POST /api/signup`, `POST /api/login`, `DELETE /api/logout`,
`GET /api/me`, `GET /api/csrf`.

Details: `{{API_NAME}}/docs/auth.md` and `{{CLIENT_NAME}}/docs/auth.md`.

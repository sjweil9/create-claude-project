# {{PROJECT_NAME}}

Full-stack pair scaffolded by `create-claude-project react-rails --jwt`:

- **`{{API_NAME}}/`** — Rails API (API-only, PostgreSQL, Redis, sidekiq
  worker; Dockerized dev)
- **`{{CLIENT_NAME}}/`** — React client (Vite + TypeScript, npm, Tailwind;
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
`bin/rails server` and the client with `npm run dev`; the proxy targets
`http://localhost:3000`.

## Auth: JWT + rotating refresh token

Sign-up/login is wired end to end with a hand-rolled token pair — no auth
framework, every moving part visible in the code:

- Login returns a **15-minute JWT access token** kept *in memory only*
  (never localStorage) and sent as `Authorization: Bearer …`.
- A **30-day refresh token** rides an httpOnly cookie. Each is single-use:
  `POST /api/refresh` rotates it; replaying a spent token revokes the whole
  family (reuse detection). Only a SHA-256 digest is stored server-side.
- On page reload the client silently refreshes to rebuild its access token;
  on a 401 it refreshes once and retries.

Endpoints: `POST /api/signup`, `POST /api/login`, `DELETE /api/logout`,
`POST /api/refresh`, `GET /api/me`.

Details: `{{API_NAME}}/docs/auth.md` and `{{CLIENT_NAME}}/docs/auth.md`.

# Dev Environment

The app runs either directly on the host or in Docker — both are first-class:

```sh
bun run dev          # host: http://localhost:5173
docker compose up    # container: http://localhost:5173 (builds on first run)
                     # WEB_PORT=5273 docker compose up — another host port
```

Dependencies are managed with **bun** (`bun install`, `bun add <pkg>`,
`bun add -d <pkg>`). The container keeps its own `node_modules` in a named
volume (linux binaries), so it never conflicts with a host `bun install`.
Lint, typecheck, and tests run on the host as usual (`bun run lint`,
`bun x tsc -b`, `bun run test`).

## Talking to a backend

All HTTP goes through the Axios client (`src/lib/api/client.ts`), whose
default base URL is `/api`. The Vite dev server proxies `/api/*` to the
backend (see `server.proxy` in `vite.config.ts`), so the browser keeps a
single origin and no CORS setup is needed. The proxy target is
`http://localhost:3000` by default and configurable via
`VITE_API_PROXY_TARGET`.

To pair with a Dockerized backend — e.g. a Rails app created by
`create-claude-project`, which puts its services on a `<backend>_dev`
compose network — edit `docker-compose.yml`:

1. Uncomment the `networks:` block and set the backend's network name.
2. Uncomment `VITE_API_PROXY_TARGET: http://app:3000` (the Rails scaffold's
   app service name is `app`).

Then `docker compose up` here joins the backend's network and `/api/*`
requests reach it — no ports beyond the dev server's are exposed.

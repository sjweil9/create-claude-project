# Dev Environment (Dockerized)

Development runs entirely in Docker — the host machine needs Docker (with
the compose plugin) and nothing else: no ruby gems, no PostgreSQL, no Redis.

## Layout

- `Dockerfile.dev` — dev image: ruby + build libraries (libpq etc.).
  Tailwind runs via tailwindcss-rails' standalone binary; node and yarn are
  included only for projects generated with explicit jsbundling/cssbundling
  flags. Source is bind-mounted; gems persist in the `bundle_cache` volume,
  any npm packages in `node_modules`.
- `docker-compose.yml` — `app` (Rails), `db` (PostgreSQL), `redis`, all on
  the `{{PROJECT_NAME}}_dev` network. Database credentials reach the app via
  `DB_HOST`/`DB_USERNAME`/`DB_PASSWORD` (see `config/database.yml`);
  `REDIS_URL` points at the redis service.
- `scripts/docker-setup` — idempotent bootstrap: builds the image, installs
  gems, finishes deferred installers (tailwind, devise), prepares the
  database. Re-run it any time it's safe to.

## Daily use

```sh
docker compose up                 # run the app at http://localhost:3000
APP_PORT=3100 docker compose up   # ...on another host port if 3000 is taken
docker compose run --rm app ...   # any app command, e.g.:
docker compose run --rm app bin/rails console
docker compose run --rm app bin/rails test
docker compose run --rm app bundle exec rubocop
docker compose run --rm app bundle install     # after Gemfile changes
```

The quality-gate hooks (`scripts/claude-hooks/`) detect the compose setup
and run rubocop/tests through the container automatically.

## Pairing with a frontend

The compose network is named `{{PROJECT_NAME}}_dev` so other compose
projects can join it and reach this app at `http://app:3000`. A React app
created by `create-claude-project` ships a commented-out block in its
`docker-compose.yml` for exactly this.

## Notes

- `db` and `redis` are intentionally not exposed on host ports; uncomment
  the `ports:` lines in `docker-compose.yml` if you need a GUI client.
- Postgres data persists in the `postgres_data` volume across restarts;
  `docker compose down -v` wipes it.

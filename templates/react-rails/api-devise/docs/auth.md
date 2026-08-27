# Auth: session cookie via Devise (API side)

Sign-up/login for the React client backed by **Devise** (warden +
`database_authenticatable`), exposed through custom JSON controllers — the
endpoint contract is identical to the hand-rolled session variant, so the
client code is the same either way.

## How it works

- Rails keeps the warden-serialized user id in its standard **encrypted,
  httpOnly session cookie**. JavaScript can never read it, so XSS cannot
  steal the credential. API mode strips the session middleware, so
  `config/application.rb` adds `ActionDispatch::Cookies` and
  `ActionDispatch::Session::CookieStore` back (Devise inserts
  `Warden::Manager` itself).
- Devise's own routes/controllers/views are skipped
  (`devise_for :users, skip: :all` registers only the mapping); the custom
  controllers use Devise's model and helper API directly:
  `find_for_database_authentication`, `valid_password?`, `sign_in`,
  `sign_out`, `user_signed_in?`. `ApplicationController#authenticate_user!`
  shadows Devise's helper so failures are JSON 401s, never redirects.
- In development the client's Vite dev server proxies `/api/*` here, so the
  cookie flows on a single browser origin — CORS (`config/initializers/
  cors.rb`) only matters if the client ever calls the API host directly.
- Because the browser attaches the cookie to *any* request to this origin —
  even ones forged by a malicious site — state-changing endpoints require a
  **CSRF token**: the SPA reads it from `GET /api/csrf` and echoes it in the
  `X-CSRF-Token` header. The token rotates with the session
  (`reset_session`), so the client refetches it after login/signup/logout.
- `reset_session` on login also prevents session fixation.
- `same_site: :lax` on the session cookie assumes the SPA and API are
  same-site (localhost in dev, sibling subdomains of one parent domain in
  production). For truly cross-site deployments you'd need
  `same_site: :none` + `secure: true` — browsers are increasingly hostile to
  that; prefer a shared parent domain.
- Growing the feature set is a matter of enabling Devise modules on the
  model (`:recoverable`, `:confirmable`, `:lockable`, ...) plus their
  columns and JSON endpoints; see `config/initializers/devise.rb`.

## Endpoints

| Route | Purpose |
|---|---|
| `POST /api/signup` | create account, log in (`{ user: { email, password, password_confirmation } }`) |
| `POST /api/login` | authenticate (`{ email, password }`) |
| `DELETE /api/logout` | clear the session |
| `GET /api/me` | current user for a live session, else 401 |
| `GET /api/csrf` | CSRF token for the current session |

## Key files

- `app/controllers/application_controller.rb` — CSRF protection, JSON
  `authenticate_user!`, `log_in`
- `app/controllers/{sessions,registrations,csrf,me}_controller.rb`
- `app/models/user.rb` — Devise modules
- `config/initializers/devise.rb` — trimmed Devise config (replaces
  `devise:install`)
- `config/routes.rb` — `devise_for :users, skip: :all` + custom /api routes
- `config/application.rb` — session middleware re-added for API mode

# Auth: session cookie (API side)

Hand-rolled sign-up/login for the React client — `has_secure_password` +
bcrypt, no auth gem, so every moving part is visible in the code.

## How it works

- Rails keeps the user id in its standard **encrypted, httpOnly session
  cookie**. JavaScript can never read it, so XSS cannot steal the credential.
  API mode strips the session middleware, so `config/application.rb` adds
  `ActionDispatch::Cookies` and `ActionDispatch::Session::CookieStore` back.
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

## Endpoints

| Route | Purpose |
|---|---|
| `POST /api/signup` | create account, log in (`{ user: { email, password, password_confirmation } }`) |
| `POST /api/login` | authenticate (`{ email, password }`) |
| `DELETE /api/logout` | clear the session |
| `GET /api/me` | current user for a live session, else 401 |
| `GET /api/csrf` | CSRF token for the current session |

## Key files

- `app/controllers/application_controller.rb` — CSRF protection,
  `current_user`, `log_in`
- `app/controllers/{sessions,registrations,csrf,me}_controller.rb`
- `app/models/user.rb` — `has_secure_password`, email normalization
- `config/application.rb` — session middleware re-added for API mode

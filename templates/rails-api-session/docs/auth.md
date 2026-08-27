# Auth: session cookie (API-only app)

Hand-rolled sign-up/login for API clients — `has_secure_password` + bcrypt,
no auth gem, so every moving part is visible in the code. Same wiring as the
API half of a `react-rails` project; here there is no bundled frontend, so
this doc walks through exercising it directly (e.g. from Postman).

## How it works

- Rails keeps the user id in its standard **encrypted, httpOnly session
  cookie**. A browser's JavaScript can never read it, so XSS cannot steal
  the credential; API clients like Postman just store and replay it like any
  cookie. `rails new --api` strips the session middleware, so
  `config/application.rb` adds `ActionDispatch::Cookies` and
  `ActionDispatch::Session::CookieStore` back.
- Because a browser attaches the cookie to *any* request to this origin —
  even ones forged by a malicious site — state-changing endpoints require a
  **CSRF token**: read it from `GET /api/csrf` and echo it in the
  `X-CSRF-Token` header. The token is bound to the session and rotates with
  it (`reset_session`), so fetch a fresh one after login/signup/logout.
- `reset_session` on login also prevents session fixation.
- `same_site: :lax` on the session cookie assumes any browser frontend is
  same-site with the API (localhost in dev, sibling subdomains of one parent
  domain in production). `config/initializers/cors.rb` allows a
  cross-origin browser client at `FRONTEND_ORIGIN` (default
  `http://localhost:5173`) with credentials; non-browser clients are never
  subject to CORS.

## Endpoints

| Route | Purpose |
|---|---|
| `POST /api/signup` | create account, log in (`{ user: { email, password, password_confirmation } }`) |
| `POST /api/login` | authenticate (`{ email, password }`) |
| `DELETE /api/logout` | clear the session |
| `GET /api/me` | current user for a live session, else 401 |
| `GET /api/csrf` | CSRF token for the current session |

Every other controller inherits `before_action :authenticate_user!` from
`ApplicationController` — new endpoints are login-protected unless they
explicitly `skip_before_action :authenticate_user!`.

## Walkthrough: logging in from Postman

Start the app (`docker compose up`, or `bin/dev` without Docker) — base URL
`http://localhost:3000`. Postman stores and replays cookies automatically
(the cookie jar is on by default), which is all the session flow needs.

1. **Get a CSRF token** — `GET http://localhost:3000/api/csrf`.
   The response is `{ "csrfToken": "..." }`, and the response's `Set-Cookie`
   gives Postman the session cookie the token is bound to. Copy the token.

2. **Sign up** — `POST http://localhost:3000/api/signup` with headers
   `Content-Type: application/json` and `X-CSRF-Token: <token from step 1>`,
   and a raw JSON body:

   ```json
   {
     "user": {
       "email": "you@example.com",
       "password": "password123",
       "password_confirmation": "password123"
     }
   }
   ```

   `201 Created` returns the user and logs you in — the rotated session
   cookie in the response is now your authenticated session. Validation
   problems come back as `422` with `{ "errors": [...] }`.

3. **Prove you're logged in** — `GET http://localhost:3000/api/me` → `200`
   with `{ "user": { ... } }`. No CSRF header needed; GETs are exempt.

4. **Log out** — signup rotated the session, so the step-1 token is dead:
   `GET /api/csrf` again, then `DELETE http://localhost:3000/api/logout`
   with the fresh token in `X-CSRF-Token` → `204 No Content`. `GET /api/me`
   now returns `401`.

5. **Log in again** — fresh token from `GET /api/csrf`, then
   `POST http://localhost:3000/api/login` with `X-CSRF-Token` and body
   `{ "email": "you@example.com", "password": "password123" }` → `200` plus
   a logged-in session. Wrong credentials return `401` with a deliberately
   vague `"Invalid email or password"`.

Rule of thumb: before every POST/DELETE, `GET /api/csrf` and echo the result
in `X-CSRF-Token`. To automate that in Postman, add a **Tests** script to
the csrf request —

```js
pm.collectionVariables.set("csrfToken", pm.response.json().csrfToken);
```

— and set `X-CSRF-Token: {{csrfToken}}` on the mutating requests.

### Troubleshooting

- `401 { "error": "Not authenticated" }` — no live session: log in, and
  check Postman's cookie jar isn't disabled for the request.
- `422 ActionController::InvalidAuthenticityToken` — missing or stale
  `X-CSRF-Token` (it rotates on login/signup/logout): refetch `/api/csrf`.
- Cookie never sticks — the session cookie is `secure` in production, so
  over plain HTTP it only works in development/test.

## Key files

- `app/controllers/application_controller.rb` — CSRF protection,
  `current_user`, `authenticate_user!`, `log_in`
- `app/controllers/{sessions,registrations,csrf,me}_controller.rb`
- `app/models/user.rb` — `has_secure_password`, email normalization
- `config/application.rb` — session middleware re-added for API mode
- `config/initializers/cors.rb` — browser clients on another origin

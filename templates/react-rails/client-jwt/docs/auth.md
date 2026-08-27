# Auth: JWT + rotating refresh token (client side)

Sign-up/login against the sibling Rails API using a **short-lived JWT access
token** plus a **rotating refresh token** in an httpOnly cookie.

## How it works

- The access token (15 min TTL) lives **in memory only** in
  `src/lib/api/client.ts` — never localStorage — so XSS can't exfiltrate a
  long-lived credential. A request interceptor sends it as
  `Authorization: Bearer …`.
- Longevity comes from the refresh cookie: `withCredentials: true` carries it
  on every `/api/*` call (through the Vite dev-server proxy in development,
  keeping a single browser origin). On a 401, a response interceptor calls
  `POST /api/refresh` once and retries the original request. Each refresh
  token is single-use — the API rotates it and detects reuse.
- On page reload the in-memory token is gone; `bootstrap()` in
  `src/stores/useAuthStore.ts` silently calls `/api/refresh` to rebuild it,
  then `GET /api/me`.
- `ProtectedRoute` (`src/features/auth/`) gates routes on the store's status
  and redirects to `/login`.

## Key files

- `src/lib/api/client.ts` — Axios instance, bearer header, refresh-and-retry
- `src/lib/api/auth.ts` — signup/login/logout/me calls
- `src/stores/useAuthStore.ts` — auth state + silent-refresh bootstrap
- `src/features/auth/` — LoginPage, SignupPage, ProtectedRoute

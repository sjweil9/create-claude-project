# Auth: session cookie (client side)

Sign-up/login against the sibling Rails API using its **encrypted, httpOnly
session cookie**. JavaScript never sees the credential, so XSS cannot steal
it.

## How it works

- The Axios client (`src/lib/api/client.ts`) sets `withCredentials: true`,
  so the browser attaches the session cookie to every `/api/*` call. In
  development those calls go through the Vite dev-server proxy
  (`vite.config.ts`), keeping a single browser origin.
- State-changing requests need a **CSRF token**: the client fetches it from
  `GET /api/csrf` (lazily, before the first non-GET) and echoes it in the
  `X-CSRF-Token` header via a request interceptor. Login/signup/logout rotate
  the session, so `src/lib/api/auth.ts` refetches the token after each.
- `src/stores/useAuthStore.ts` holds `user` + `status`
  (`loading`/`authenticated`/`unauthenticated`). On page load `bootstrap()`
  calls `GET /api/me` — the cookie (if any) identifies the user.
- `ProtectedRoute` (`src/features/auth/`) gates routes on that status and
  redirects to `/login`.

## Key files

- `src/lib/api/client.ts` — Axios instance, credentials, CSRF interceptor
- `src/lib/api/auth.ts` — signup/login/logout/me calls
- `src/stores/useAuthStore.ts` — auth state + actions
- `src/features/auth/` — LoginPage, SignupPage, ProtectedRoute

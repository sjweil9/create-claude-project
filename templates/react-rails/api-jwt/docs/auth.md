# Auth: JWT + rotating refresh token (API side)

Hand-rolled sign-up/login for the React client — `has_secure_password` +
bcrypt and the `jwt` gem, no auth framework, so every moving part is visible
in the code.

## How it works

- Login returns a **15-minute JWT access token** (`app/models/access_token.rb`)
  in the JSON body. The client keeps it *in memory only* (never localStorage)
  and sends it as `Authorization: Bearer …`. Stateless verification via
  `secret_key_base` — no shared session store needed.
- Longevity comes from a **30-day refresh token** in an httpOnly cookie
  (API mode strips cookie middleware, so `config/application.rb` adds
  `ActionDispatch::Cookies` back). Each refresh token is single-use:
  `POST /api/refresh` revokes it and issues a new pair (**rotation**).
  Presenting an already-revoked token is treated as theft and revokes every
  active token for that user (**reuse detection**).
- Only a SHA-256 digest of the refresh token is stored
  (`app/models/refresh_token.rb`), so a database leak yields nothing
  replayable.
- On page reload the client silently calls `/api/refresh` to rebuild its
  in-memory access token.
- Logout revokes the refresh token server-side; the access token simply
  expires (≤15 min).

## Endpoints

| Route | Purpose |
|---|---|
| `POST /api/signup` | create account, returns user + access token (`{ user: { email, password, password_confirmation } }`) |
| `POST /api/login` | authenticate (`{ email, password }`), returns user + access token |
| `DELETE /api/logout` | revoke the refresh token |
| `POST /api/refresh` | rotate the refresh token, returns a new access token |
| `GET /api/me` | current user for a valid bearer token, else 401 |

## Key files

- `app/controllers/application_controller.rb` — bearer auth, token issuance,
  refresh cookie
- `app/controllers/{sessions,registrations,refreshes,me}_controller.rb`
- `app/models/access_token.rb` — JWT encode/decode (HS256, 15 min TTL)
- `app/models/refresh_token.rb` — digest storage, rotation, revocation
- `app/models/user.rb` — `has_secure_password`, `has_many :refresh_tokens`

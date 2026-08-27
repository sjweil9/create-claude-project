import axios, { AxiosError } from 'axios'

// Every error rejected by the client is normalized to this class, so
// components and query hooks handle a single error type (and stack traces
// survive, since it is a real Error).
export class ApiError extends Error {
  readonly status: number | null
  readonly details: unknown

  constructor(message: string, status: number | null, details: unknown) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.details = details
  }
}

export function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError
}

// All HTTP goes through this client (see docs/code-standards.md). Auth is an
// httpOnly Rails session cookie — withCredentials sends it on every request.
export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? '/api',
  headers: { 'Content-Type': 'application/json' },
  timeout: 15_000,
  withCredentials: true,
})

// Rails only accepts state-changing requests that echo the CSRF token bound
// to the current session. It is fetched lazily before the first non-GET and
// refreshed after login/signup/logout (reset_session rotates it) — see
// src/lib/api/auth.ts and docs/auth.md.
let csrfToken: string | null = null

export async function refreshCsrfToken(): Promise<void> {
  const { data } = await api.get<{ csrfToken: string }>('/csrf')
  csrfToken = data.csrfToken
}

const SAFE_METHODS = ['get', 'head', 'options']

api.interceptors.request.use(async (config) => {
  const method = (config.method ?? 'get').toLowerCase()
  if (!SAFE_METHODS.includes(method)) {
    if (!csrfToken) await refreshCsrfToken()
    if (csrfToken) config.headers.set('X-CSRF-Token', csrfToken)
  }
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => Promise.reject(normalizeError(error)),
)

function normalizeError(error: AxiosError): ApiError {
  const data = error.response?.data
  let message = error.message
  if (typeof data === 'object' && data !== null) {
    if ('errors' in data && Array.isArray(data.errors)) {
      message = data.errors.join(', ')
    } else if ('error' in data && typeof data.error === 'string') {
      message = data.error
    }
  }
  return new ApiError(message, error.response?.status ?? null, data ?? null)
}

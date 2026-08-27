import axios, { AxiosError, type InternalAxiosRequestConfig } from 'axios'

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

const BASE_URL = import.meta.env.VITE_API_URL ?? '/api'

// All HTTP goes through this client (see docs/code-standards.md).
// withCredentials carries the httpOnly refresh-token cookie.
export const api = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 15_000,
  withCredentials: true,
})

// The access token lives only in memory — never localStorage — so XSS can't
// exfiltrate a long-lived credential. A page reload loses it; the auth store
// recovers by calling tryRefresh() (the refresh cookie survives reloads).
let accessToken: string | null = null

export function setAccessToken(token: string | null): void {
  accessToken = token
}

// Trade the refresh cookie for a new access token. Returns false when the
// cookie is missing/expired/revoked. Uses a bare axios call so a 401 here
// never re-enters the retry interceptor below.
export async function tryRefresh(): Promise<boolean> {
  try {
    const { data } = await axios.post<{ accessToken: string }>(
      `${BASE_URL}/refresh`,
      undefined,
      { withCredentials: true },
    )
    accessToken = data.accessToken
    return true
  } catch {
    accessToken = null
    return false
  }
}

api.interceptors.request.use((config) => {
  if (accessToken) config.headers.set('Authorization', `Bearer ${accessToken}`)
  return config
})

type RetriableConfig = InternalAxiosRequestConfig & { _retried?: boolean }

api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    // Access tokens are short-lived by design; on 401, refresh once and
    // retry the original request.
    const config = error.config as RetriableConfig | undefined
    if (
      error.response?.status === 401 &&
      config &&
      !config._retried &&
      (await tryRefresh())
    ) {
      config._retried = true
      return api(config)
    }
    return Promise.reject(normalizeError(error))
  },
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

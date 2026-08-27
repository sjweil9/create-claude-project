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

// All HTTP goes through this client (see docs/code-standards.md).
export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? '/api',
  headers: { 'Content-Type': 'application/json' },
  timeout: 15_000,
})

api.interceptors.request.use((config) => {
  // Attach auth credentials here once the app has a session concept.
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    const data = error.response?.data
    const message =
      (typeof data === 'object' &&
        data !== null &&
        'message' in data &&
        typeof data.message === 'string' &&
        data.message) ||
      error.message
    return Promise.reject(
      new ApiError(message, error.response?.status ?? null, data ?? null),
    )
  },
)

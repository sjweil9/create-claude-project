import { api, setAccessToken, tryRefresh } from './client'

export interface User {
  id: number
  email: string
  created_at: string
}

interface AuthResponse {
  user: User
  accessToken: string
}

export async function signup(
  email: string,
  password: string,
  passwordConfirmation: string,
): Promise<User> {
  const { data } = await api.post<AuthResponse>('/signup', {
    user: { email, password, password_confirmation: passwordConfirmation },
  })
  setAccessToken(data.accessToken)
  return data.user
}

export async function login(email: string, password: string): Promise<User> {
  const { data } = await api.post<AuthResponse>('/login', { email, password })
  setAccessToken(data.accessToken)
  return data.user
}

// Revokes the refresh token server-side; the access token simply expires.
export async function logout(): Promise<void> {
  await api.delete('/logout')
  setAccessToken(null)
}

// Resolves to the user for a valid bearer token, rejects with 401 otherwise.
export async function fetchCurrentUser(): Promise<User> {
  const { data } = await api.get<{ user: User }>('/me')
  return data.user
}

export { tryRefresh }

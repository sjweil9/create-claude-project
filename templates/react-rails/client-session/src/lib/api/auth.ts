import { api, refreshCsrfToken } from './client'

export interface User {
  id: number
  email: string
  created_at: string
}

interface UserResponse {
  user: User
}

export async function signup(
  email: string,
  password: string,
  passwordConfirmation: string,
): Promise<User> {
  const { data } = await api.post<UserResponse>('/signup', {
    user: { email, password, password_confirmation: passwordConfirmation },
  })
  await refreshCsrfToken() // logging in rotates the session, and the token with it
  return data.user
}

export async function login(email: string, password: string): Promise<User> {
  const { data } = await api.post<UserResponse>('/login', { email, password })
  await refreshCsrfToken()
  return data.user
}

export async function logout(): Promise<void> {
  await api.delete('/logout')
  await refreshCsrfToken()
}

// Resolves to the user for a live session cookie, rejects with 401 otherwise.
export async function fetchCurrentUser(): Promise<User> {
  const { data } = await api.get<UserResponse>('/me')
  return data.user
}

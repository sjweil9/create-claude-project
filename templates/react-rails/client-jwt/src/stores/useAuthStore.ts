import { create } from 'zustand'
import * as authApi from '../lib/api/auth'
import type { User } from '../lib/api/auth'

// Auth state is the one piece of server-derived state kept in a store rather
// than the query cache: routing decisions (ProtectedRoute) need it
// synchronously, and login/logout must update it imperatively.
type AuthStatus = 'loading' | 'authenticated' | 'unauthenticated'

interface AuthState {
  user: User | null
  status: AuthStatus
  bootstrap: () => Promise<void>
  signup: (
    email: string,
    password: string,
    passwordConfirmation: string,
  ) => Promise<void>
  login: (email: string, password: string) => Promise<void>
  logout: () => Promise<void>
}

export const useAuthStore = create<AuthState>()((set) => ({
  user: null,
  status: 'loading',

  // On page load the in-memory access token is gone; try a silent refresh
  // (the refresh cookie survives reloads), then ask who we are.
  bootstrap: async () => {
    try {
      if (await authApi.tryRefresh()) {
        const user = await authApi.fetchCurrentUser()
        set({ user, status: 'authenticated' })
        return
      }
    } catch {
      // fall through to unauthenticated
    }
    set({ user: null, status: 'unauthenticated' })
  },

  signup: async (email, password, passwordConfirmation) => {
    const user = await authApi.signup(email, password, passwordConfirmation)
    set({ user, status: 'authenticated' })
  },

  login: async (email, password) => {
    const user = await authApi.login(email, password)
    set({ user, status: 'authenticated' })
  },

  logout: async () => {
    await authApi.logout()
    set({ user: null, status: 'unauthenticated' })
  },
}))

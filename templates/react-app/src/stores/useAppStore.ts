import { create } from 'zustand'

// Client-only state lives in Zustand stores; server state belongs in the
// TanStack Query cache — never duplicate one into the other.
interface AppState {
  sidebarOpen: boolean
  toggleSidebar: () => void
}

export const useAppStore = create<AppState>()((set) => ({
  sidebarOpen: false,
  toggleSidebar: () => {
    set((state) => ({ sidebarOpen: !state.sidebarOpen }))
  },
}))

import { useEffect } from 'react'
import { Link, Outlet } from '@tanstack/react-router'
import { useAuthStore } from './stores/useAuthStore'

// Root layout: shared chrome (nav, footers, providers needing router context)
// goes here; routed pages render into the Outlet.
export default function App() {
  const user = useAuthStore((state) => state.user)
  const bootstrap = useAuthStore((state) => state.bootstrap)
  const logout = useAuthStore((state) => state.logout)

  // Rebuild the session from the auth cookie once per page load.
  useEffect(() => {
    void bootstrap()
  }, [bootstrap])

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900">
      <header className="border-b border-gray-200 bg-white">
        <nav className="mx-auto flex max-w-3xl items-center justify-between px-6 py-4">
          <Link to="/" className="font-semibold">
            {'{{PROJECT_NAME}}'}
          </Link>
          {user ? (
            <div className="flex items-center gap-4 text-sm">
              <span className="text-gray-600">{user.email}</span>
              <button
                type="button"
                onClick={() => void logout()}
                className="rounded-md border border-gray-300 px-3 py-1.5 font-medium hover:bg-gray-100"
              >
                Sign out
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-4 text-sm font-medium">
              <Link
                to="/login"
                className="text-indigo-600 hover:text-indigo-500"
              >
                Log in
              </Link>
              <Link
                to="/signup"
                className="text-indigo-600 hover:text-indigo-500"
              >
                Sign up
              </Link>
            </div>
          )}
        </nav>
      </header>
      <main className="mx-auto max-w-3xl px-6 py-12">
        <Outlet />
      </main>
    </div>
  )
}

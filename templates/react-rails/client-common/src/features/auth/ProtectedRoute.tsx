import { Navigate, Outlet } from 'react-router-dom'
import { useAuthStore } from '../../stores/useAuthStore'

// Gates a route subtree on a live session; unauthenticated visitors are
// sent to /login.
export default function ProtectedRoute() {
  const status = useAuthStore((state) => state.status)

  if (status === 'loading') {
    return <p className="text-sm text-gray-500">Loading…</p>
  }
  if (status === 'unauthenticated') {
    return <Navigate to="/login" replace />
  }
  return <Outlet />
}

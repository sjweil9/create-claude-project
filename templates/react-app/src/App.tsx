import { Outlet } from 'react-router-dom'

// Root layout: shared chrome (nav, footers, providers needing router context)
// goes here; routed pages render into the Outlet.
export default function App() {
  return (
    <div className="min-h-screen bg-gray-50 text-gray-900">
      <main className="mx-auto max-w-3xl px-6 py-12">
        <Outlet />
      </main>
    </div>
  )
}

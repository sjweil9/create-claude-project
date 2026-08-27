import {
  createRootRoute,
  createRoute,
  createRouter,
} from '@tanstack/react-router'
import App from './App'
import LoginPage from './features/auth/LoginPage'
import ProtectedRoute from './features/auth/ProtectedRoute'
import SignupPage from './features/auth/SignupPage'
import HomePage from './features/home/HomePage'

// Code-based route definitions keep the scaffold self-contained; TanStack's
// file-based routing (@tanstack/router-plugin generating routeTree.gen.ts)
// is a straightforward upgrade once the route surface grows.
const rootRoute = createRootRoute({ component: App })

// Pathless layout route: everything beneath it requires a live session.
const protectedRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: 'protected',
  component: ProtectedRoute,
})

const homeRoute = createRoute({
  getParentRoute: () => protectedRoute,
  path: '/',
  component: HomePage,
})

const loginRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/login',
  component: LoginPage,
})

const signupRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/signup',
  component: SignupPage,
})

const routeTree = rootRoute.addChildren([
  protectedRoute.addChildren([homeRoute]),
  loginRoute,
  signupRoute,
])

export const router = createRouter({ routeTree })

// Registers the router's types so <Link to>, navigate(), params, etc. are
// fully type-checked app-wide.
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}

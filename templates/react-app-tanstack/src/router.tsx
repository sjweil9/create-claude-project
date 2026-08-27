import {
  createRootRoute,
  createRoute,
  createRouter,
} from '@tanstack/react-router'
import App from './App'
import HomePage from './features/home/HomePage'

// Code-based route definitions keep the scaffold self-contained; TanStack's
// file-based routing (@tanstack/router-plugin generating routeTree.gen.ts)
// is a straightforward upgrade once the route surface grows.
const rootRoute = createRootRoute({ component: App })

const homeRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  component: HomePage,
})

const routeTree = rootRoute.addChildren([homeRoute])

export const router = createRouter({ routeTree })

// Registers the router's types so <Link to>, navigate(), params, etc. are
// fully type-checked app-wide.
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}

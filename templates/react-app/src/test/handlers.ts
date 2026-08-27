import type { RequestHandler } from 'msw'

// Default request stubs shared by all tests; individual tests add overrides
// with server.use(...). Example:
//   http.get('/api/users', () => HttpResponse.json([{ id: 1 }]))
export const handlers: RequestHandler[] = []

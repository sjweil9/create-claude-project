/// <reference types="vitest/config" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    // The API client's default base URL is /api; the dev server proxies it
    // to the backend so the browser keeps a single origin (no CORS). Point
    // VITE_API_PROXY_TARGET at a Dockerized backend to pair with it — see
    // docker-compose.yml and docs/dev-environment.md.
    proxy: {
      '/api': {
        target: process.env.VITE_API_PROXY_TARGET ?? 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },
  test: {
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
  },
})

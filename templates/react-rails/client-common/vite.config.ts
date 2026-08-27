/// <reference types="vitest/config" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    // The API client's base URL is /api; the dev server proxies it to the
    // Rails API so the browser keeps a single origin — the auth cookie rides
    // along with no CORS involved. In Docker the compose file points
    // VITE_API_PROXY_TARGET at http://app:3000 on the API's network.
    proxy: {
      '/api': {
        target: process.env.VITE_API_PROXY_TARGET ?? 'http://localhost:3000',
        // Keep the browser's Host header so Rails' CSRF origin check
        // (Origin vs request.base_url) holds through the proxy.
        changeOrigin: false,
      },
    },
  },
  test: {
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
  },
})

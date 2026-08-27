/// <reference types="vite/client" />

// Type every env var the app reads — import.meta.env is `any`-free that way.
interface ImportMetaEnv {
  readonly VITE_API_URL?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

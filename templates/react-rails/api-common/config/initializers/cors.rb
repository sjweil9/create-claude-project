# Cross-origin config for the React client. In development the client's Vite
# dev server proxies /api/* here, so the browser keeps a single origin and
# CORS is never exercised — this config only matters when the client calls
# the API directly (VITE_API_URL set to this host). `credentials: true` lets
# the browser attach the auth cookie on those calls; wildcard origins are NOT
# allowed in that mode, so list them.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:5173")

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end

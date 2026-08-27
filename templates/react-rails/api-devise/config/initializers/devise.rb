# Trimmed Devise configuration for an API-only app: session-cookie auth
# behind custom JSON controllers — no Devise views, routes, or redirects.
# This file replaces `rails generate devise:install` (scripts/docker-setup
# skips the generator when it exists); run the generator's full template
# through the Devise docs if you enable mailer-backed modules later.
Devise.setup do |config|
  require "devise/orm/active_record"

  # Used by Devise mailers (:recoverable, :confirmable) if enabled later.
  config.mailer_sender = "noreply@{{PROJECT_NAME}}.example"

  # Normalize email the way the User model expects.
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]

  # Session-cookie auth only — no HTTP Basic.
  config.skip_session_storage = [ :http_auth ]

  # bcrypt cost: fast in tests, strong everywhere else.
  config.stretches = Rails.env.test? ? 1 : 12

  config.password_length = 8..128

  # API-only: no navigational (HTML) formats, so failed authentication can
  # never redirect — it falls through to the JSON 401 in
  # ApplicationController#authenticate_user!.
  config.navigational_formats = []

  config.sign_out_via = :delete
end

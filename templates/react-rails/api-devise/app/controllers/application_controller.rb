class ApplicationController < ActionController::API
  include ActionController::Cookies
  # API mode omits CSRF protection, but cookie-authenticated endpoints need it:
  # the browser attaches the session cookie to ANY request to this origin,
  # including ones forged by other sites. The SPA proves it's really our
  # frontend by echoing the token from GET /api/csrf in the X-CSRF-Token
  # header.
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :exception

  # Secure by default: every endpoint requires a logged-in user unless the
  # controller explicitly opts out (skip_before_action :authenticate_user!).
  # current_user/user_signed_in? come from Devise's warden integration (the
  # :user mapping is defined by devise_for in config/routes.rb).
  before_action :authenticate_user!

  private

  # Shadows Devise's authenticate_user! so a missing session renders a JSON
  # 401 instead of going through Devise's failure app.
  def authenticate_user!
    render json: { error: "Not authenticated" }, status: :unauthorized unless user_signed_in?
  end

  def log_in(user)
    # Rotating the session id on login prevents session fixation (and rotates
    # the CSRF token with it — the client refetches it after login/signup).
    reset_session
    sign_in(user)
  end

  def user_json(user)
    { user: user.as_json(only: %i[id email created_at]) }
  end
end

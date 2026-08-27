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
  before_action :authenticate_user!

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    render json: { error: "Not authenticated" }, status: :unauthorized unless current_user
  end

  def log_in(user)
    # Rotating the session id on login prevents session fixation.
    reset_session
    session[:user_id] = user.id
  end

  def user_json(user)
    { user: user.as_json(only: %i[id email created_at]) }
  end
end

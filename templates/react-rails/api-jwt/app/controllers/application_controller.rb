class ApplicationController < ActionController::API
  include ActionController::Cookies

  REFRESH_COOKIE = :refresh_token

  # Secure by default: every endpoint requires a valid bearer token unless
  # the controller explicitly opts out (skip_before_action
  # :authenticate_user!).
  before_action :authenticate_user!

  private

  def current_user
    return @current_user if defined?(@current_user)

    token = request.headers["Authorization"]&.delete_prefix("Bearer ")
    user_id = AccessToken.decode(token)
    @current_user = user_id && User.find_by(id: user_id)
  end

  def authenticate_user!
    render json: { error: "Not authenticated" }, status: :unauthorized unless current_user
  end

  # Issues both halves of the token pair: the access token goes back in the
  # JSON body (client keeps it in memory), the refresh token in an httpOnly
  # cookie JS can never read.
  def issue_tokens(user)
    _record, raw = RefreshToken.issue_for(user)
    set_refresh_cookie(raw)
    { accessToken: AccessToken.encode(user) }
  end

  def set_refresh_cookie(raw)
    cookies[REFRESH_COOKIE] = {
      value: raw,
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?,
      expires: RefreshToken::TTL.from_now,
      # Hardening option: scope with `path: "/api/refresh"` so the cookie is
      # only ever sent to the refresh endpoint (then revoke on logout by
      # other means).
    }
  end

  def clear_refresh_cookie
    cookies.delete(REFRESH_COOKIE)
  end

  def user_json(user)
    { user: user.as_json(only: %i[id email created_at]) }
  end
end

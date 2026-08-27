class RefreshesController < ApplicationController
  # Authenticated by the refresh cookie itself, not a (possibly expired)
  # access token.
  skip_before_action :authenticate_user!

  # POST /api/refresh — trade the refresh cookie for a new access token,
  # rotating the refresh token in the process (each one is single-use).
  def create
    token = RefreshToken.find_by_raw(cookies[REFRESH_COOKIE])

    if token.nil? || token.expires_at.past?
      clear_refresh_cookie
      return render json: { error: "Invalid refresh token" }, status: :unauthorized
    end

    # A revoked token being replayed means it was already spent — either a
    # race, or someone stole it. Fail closed: revoke the whole family so both
    # the attacker and the victim must log in again.
    if token.revoked_at?
      token.user.refresh_tokens.active.each(&:revoke!)
      clear_refresh_cookie
      return render json: { error: "Invalid refresh token" }, status: :unauthorized
    end

    token.revoke!
    render json: user_json(token.user).merge(issue_tokens(token.user))
  end
end

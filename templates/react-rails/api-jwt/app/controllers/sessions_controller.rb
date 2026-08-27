class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  # POST /api/login
  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])
    if user
      render json: user_json(user).merge(issue_tokens(user))
    else
      # Same message whether the email or the password was wrong — don't leak
      # which accounts exist.
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # DELETE /api/logout — revoke the refresh token server-side so it can't be
  # replayed. The access token stays valid until it expires (≤15 min); truly
  # instant revocation would require a denylist check on every request.
  def destroy
    RefreshToken.find_by_raw(cookies[REFRESH_COOKIE])&.revoke!
    clear_refresh_cookie
    head :no_content
  end
end

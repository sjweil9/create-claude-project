class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  # POST /api/login
  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])
    if user
      log_in(user)
      render json: user_json(user)
    else
      # Same message whether the email or the password was wrong — don't leak
      # which accounts exist.
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # DELETE /api/logout
  def destroy
    reset_session
    head :no_content
  end
end

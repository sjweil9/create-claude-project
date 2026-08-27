class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  # POST /api/login
  def create
    # find_for_database_authentication applies Devise's case/whitespace
    # normalization; valid_password? is a constant-time bcrypt compare.
    user = User.find_for_database_authentication(email: params[:email])
    if user&.valid_password?(params[:password].to_s)
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
    sign_out(:user)
    reset_session
    head :no_content
  end
end

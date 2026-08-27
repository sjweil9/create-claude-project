class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!

  # POST /api/signup
  def create
    user = User.new(user_params)
    if user.save
      log_in(user)
      render json: user_json(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

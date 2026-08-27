class MeController < ApplicationController
  # GET /api/me
  def show
    render json: user_json(current_user)
  end
end

class CsrfController < ApplicationController
  skip_before_action :authenticate_user!

  # GET /api/csrf — hands the SPA a CSRF token bound to its session. Reading
  # it requires a successful same-origin (or CORS) request, which forged
  # cross-site pages can't do.
  def show
    render json: { csrfToken: form_authenticity_token }
  end
end

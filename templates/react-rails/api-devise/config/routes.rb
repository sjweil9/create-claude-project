Rails.application.routes.draw do
  # Registers the :user Devise mapping (warden scope, current_user helpers).
  # All endpoints are the custom JSON controllers below, so Devise's own
  # routes (and controllers/views) are skipped entirely.
  devise_for :users, skip: :all

  # Auth endpoints live under /api so the React client's dev-server proxy
  # (which forwards /api/* verbatim) reaches them on a single browser origin.
  scope :api do
    get    "csrf",   to: "csrf#show"
    post   "signup", to: "registrations#create"
    post   "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy"
    get    "me",     to: "me#show"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

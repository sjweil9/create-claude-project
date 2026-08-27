Rails.application.routes.draw do
  # Auth endpoints live under /api so the React client's dev-server proxy
  # (which forwards /api/* verbatim) reaches them on a single browser origin.
  scope :api do
    post   "signup",  to: "registrations#create"
    post   "login",   to: "sessions#create"
    delete "logout",  to: "sessions#destroy"
    post   "refresh", to: "refreshes#create"
    get    "me",      to: "me#show"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

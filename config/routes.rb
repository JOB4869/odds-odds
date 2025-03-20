Rails.application.routes.draw do
  get "sign_up", to: "registrations#new", as: :sign_up
  post "sign_up", to: "registrations#create"

  get "sign_in", to: "sessions#new", as: :new_session
  post "sign_in", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy", as: :sign_out

  root "home#index"
end

Rails.application.routes.draw do
  get "sign_up", to: "registrations#new", as: :sign_up
  post "sign_up", to: "registrations#create"

  get "additional_info", to: "registrations#additional_info"

  get "sign_in", to: "sessions#new", as: :new_session
  post "sign_in", to: "sessions#create"

  get "password", to: "passwords#edit", as: :edit_password
  patch "password", to: "passwords#update"

  delete "sign_out", to: "sessions#destroy", as: :sign_out

  get "password/reset", to: "password_resets#new"
  post "password/reset", to: "password_resets#create"
  get "password/reset/edit", to: "password_resets#edit"
  patch "password/reset/edit", to: "password_resets#update"

  get "users", to: "users#index"

  get "beers", to: "beers#index"

  root "home#index"
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "sign_up" => "registrations#new", as: :sign_up
  post "sign_up" => "registrations#create"
  get "sign_in" => "sessions#new", as: :sign_in
  post "sign_in" => "sessions#create"
  delete "sign_out" => "sessions#destroy", as: :sign_out

  root to: "main#index"
end

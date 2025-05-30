Rails.application.routes.draw do
  resources :products do
    member do
      get :customers
    end
    resources :buy_nows, only: [ :show ] do
      collection do
        get :purchase
        post :confirm_purchase
      end
    end
  end

  resources :carts, only: [ :show ] do
    collection do
      post :add
      delete :clear
      get :current
      delete :remove_item
      get :purchase_all
      post :confirm_purchase_all
    end
  end

  resources :buy_nows do
    member do
      get :qr_code
      patch :confirm_payment
    end
  end

  resource :user, only: [] do
    post :drink
  end

  resources :accounts, controller: "accounts"

  get "check_out_beer", to: "beers#check_out_beer", as: :check_out_beer
  post "check_out_beer", to: "beers#check_out", as: :check_out

  get "sign_up", to: "registrations#new", as: :sign_up
  post "sign_up", to: "registrations#create"

  get "additional_info", to: "registrations#additional_info"

  get "sign_in", to: "sessions#new", as: :new_session
  post "sign_in", to: "sessions#create"

  get "password", to: "passwords#edit", as: :edit_password
  patch "password", to: "passwords#update"

  delete "sign_out", to: "sessions#destroy", as: :sign_out
  get "sign_out", to: "sessions#sign_out_modal", as: :sign_out_modal

  get "password/reset", to: "password_resets#new"
  post "password/reset", to: "password_resets#create"
  get "password/reset/edit", to: "password_resets#edit"
  patch "password/reset/edit", to: "password_resets#update"

  get "users", to: "users#index"

  get "beers", to: "beers#index"

  root "home#index"
end

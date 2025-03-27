class HomeController < ApplicationController
  def index
    @user = Current.user
    @products = Product.order(created_at: :desc)
  end
end

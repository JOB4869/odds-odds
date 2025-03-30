class HomeController < ApplicationController
  before_action :set_cart

  def index
    @user = Current.user
    @products = Product.order(created_at: :desc)
  end

  private

  def set_cart
    @current_cart = Cart.find_or_create_by(user: Current.user)
  end
end

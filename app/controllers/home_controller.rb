class HomeController < ApplicationController
  def index
    @user = Current.user
    @products = Product.all
  end
end

class BeersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = Current.user
    if @user
      @buy_nows = @user.buy_nows.order(created_at: :desc).limit(5)
      @total_beers = @user.buy_nows.completed.sum(:amount)
    end
  end
end

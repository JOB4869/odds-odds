class BeersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = Current.user
    @product = Product.find_or_create_by(name: "เบียร์ ODDS") do |product|
      product.price = 33.3333333333
      product.amount = nil
    end

    if @user
      @buy_nows = @user.buy_nows.order(created_at: :desc).limit(5)
      @total_beers = @user.buy_nows.completed.where(product_id: nil).sum(:amount)
    end
  end

  def check_out_beer
  end

  def check_out
    @user = Current.user
    if @user.buy_nows.completed.where(product_id: nil).sum(:amount) > 0
      latest_buy_now = @user.buy_nows.completed.where(product_id: nil).order(created_at: :desc).first
      latest_buy_now.update(amount: latest_buy_now.amount - 1)
      redirect_to beers_path, notice: "ดื่มเบียร์สำเร็จ! ", status: :see_other,
      data: { testid: "check-out-beer-success-notice" }
    else
      redirect_to beers_path, alert: "คุณไม่มีเบียร์ในคลัง", status: :see_other,
      data: { testid: "check-out-beer-error-notice" }
    end
  end

  def buy_beer
    @user = Current.user
    amount = params[:amount].to_i
    @product = Product.find_or_create_by(name: "เบียร์ ODDS") do |product|
      product.price = 33.3333333333
      product.amount = nil
    end

    redirect_to new_buy_now_path(amount: amount, product_id: @product.id), notice: "กรุณาชำระเงิน",
    data: { testid: "buy-beer-success-notice" }
  end
end

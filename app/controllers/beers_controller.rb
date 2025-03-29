class BeersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = Current.user
    @product = Product.first # หรือใช้ product ที่ต้องการ
    if @user
      @buy_nows = @user.buy_nows.order(created_at: :desc).limit(5)
      @total_beers = @user.buy_nows.completed.sum(:amount)
    end
  end

  def check_out_beer
  end

  def check_out
    @user = Current.user
    if @user.buy_nows.completed.sum(:amount) && @user.buy_nows.completed.sum(:amount) > 0
      latest_buy_now = @user.buy_nows.completed.order(created_at: :desc).first
      latest_buy_now.update(amount: latest_buy_now.amount - 1)
      redirect_to beers_path, notice: "ดื่มเบียร์สำเร็จ! ", status: :see_other
    else
      redirect_to beers_path, alert: "คุณไม่มีเบียร์ในคลัง", status: :see_other
    end
  end
end

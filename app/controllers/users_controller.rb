class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = Current.user
  end

  def drink
    if current_user.drink_beer
      redirect_to user_dashboard_path, notice: "ดื่มเบียร์แล้ว! 🍻 เหลือ #{current_user.beer_balance} แก้ว"
    else
      redirect_to user_dashboard_path, alert: "ไม่มีเบียร์เหลือแล้ว! ไปเติมเลย! 🍺"
    end
  end
end

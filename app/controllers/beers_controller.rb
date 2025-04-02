class BeersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = Current.user
    @product = Product.first
    if @user
      @buy_nows = @user.buy_nows.order(created_at: :desc).limit(5)
      @total_beers = @user.buy_nows.completed.where(product_id: nil).sum(:amount)
    end
  end

  def check_out_beer
  end

  def check_out
    @user = Current.user

    redeemable_buy_now = @user.buy_nows
                              .completed
                              .where(product_id: nil)
                              .where("amount > 0")
                              .order(created_at: :asc)
                              .first

    if redeemable_buy_now
      ActiveRecord::Base.transaction do
        redeemable_buy_now.decrement!(:amount)
      end
      redirect_to beers_path, notice: "ดื่มเบียร์สำเร็จ! เครดิตคงเหลือ #{ @user.buy_nows.completed.where(product_id: nil).sum(:amount) } แก้ว", status: :see_other,
      data: { testid: "check-out-beer-success-notice" }
    else
      redirect_to beers_path, alert: "คุณไม่มีเครติดเบียร์คงเหลือ", status: :see_other,
      data: { testid: "check-out-beer-error-notice" }
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error decrementing beer credit for user #{@user.id}: #{e.message}"
    redirect_to beers_path, alert: "เกิดข้อผิดพลาดในการดื่มเบียร์", status: :see_other
  end
end

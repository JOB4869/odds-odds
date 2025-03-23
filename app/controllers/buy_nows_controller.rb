class BuyNowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_buy_now, only: [ :show, :update ]

  def new
    @buy_now = Current.user.buy_nows.build(amount: params[:amount])
  end

  def create
    @buy_now = Current.user.buy_nows.build(buy_now_params)

    if @buy_now.save
      redirect_to beers_path, notice: "อัพโหลดสลิปเรียบร้อย รอการตรวจสอบ"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # แสดงหน้าอัพโหลดสลิป
  end

  def update
    if @buy_now.update(buy_now_params)
      if @buy_now.proof_of_payment.attached? && @buy_now.completed?
        redirect_to beers_path, notice: "\u0E01\u0E32\u0E23\u0E0A\u0E33\u0E23\u0E30\u0E40\u0E07\u0E34\u0E19\u0E40\u0E2A\u0E23\u0E47\u0E08\u0E2A\u0E21\u0E1A\u0E39\u0E23\u0E13\u0E4C"
      else
        redirect_to beers_path, notice: "\u0E2D\u0E31\u0E1E\u0E42\u0E2B\u0E25\u0E14\u0E2A\u0E25\u0E34\u0E1B\u0E40\u0E23\u0E35\u0E22\u0E1A\u0E23\u0E49\u0E2D\u0E22 \u0E23\u0E2D\u0E01\u0E32\u0E23\u0E15\u0E23\u0E27\u0E08\u0E2A\u0E2D\u0E1A"
      end
    else
      render :show
    end
  end

  def qr_code
    @buy_now = BuyNow.find(params[:id])
  end

  def confirm_payment
    if params[:proof_of_payment].present?
      @buy_now.proof_of_payment.attach(params[:proof_of_payment])
      @buy_now.update(status: "completed")
      redirect_to user_dashboard_path, notice: "เติมเบียร์สำเร็จ! 🍺"
    else
      redirect_to qr_code_path(@buy_now), alert: "กรุณาอัปโหลดสลิปการชำระเงิน"
    end
  end

  private

  def set_buy_now
    @buy_now = Current.user.buy_nows.find(params[:id])
  end

  def buy_now_params
    params.require(:buy_now).permit(:amount, :proof_of_payment, :status)
  end
end

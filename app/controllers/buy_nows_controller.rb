class BuyNowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_buy_now, only: [ :show, :update ]

  def new
    @buy_now = Current.user.buy_nows.build(amount: params[:amount])
  end

  def create
    @buy_now = Current.user.buy_nows.build(buy_now_params.merge(status: :completed))

    if @buy_now.save
      redirect_to beers_path, notice: "อัปโหลดสลิปเรียบร้อย"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
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
    params.require(:buy_now).permit(:amount, :proof_of_payment)
  end
end

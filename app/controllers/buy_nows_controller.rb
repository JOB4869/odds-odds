class BuyNowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_buy_now, only: [ :show, :update, :confirm_payment ]
  before_action :set_product, only: [ :purchase, :show, :confirm_purchase ]

  def index
    @buy_nows = Current.user.buy_nows.includes(:product).order(created_at: :desc)
  end

  def new
    @buy_now = Current.user.buy_nows.build(
      amount: params[:amount]
    )
  end

  def create
    @buy_now = Current.user.buy_nows.build(buy_now_params.merge(
      status: :completed
    ))

    if @buy_now.save
      if params[:buy_now][:proof_of_payment].present?
        @buy_now.proof_of_payment.attach(params[:buy_now][:proof_of_payment])
      end
      redirect_to beers_path, notice: "อัปโหลดสลิปเรียบร้อย",
      data: { testid: "buy-now-create-success-notice" }
    else
      flash.now[:alert] = "เกิดข้อผิดพลาด: #{@buy_now.errors.full_messages.join(", ")}"
      render :new, status: :unprocessable_entity
    end
  end

  def purchase
    @buy_now = Current.user.buy_nows.build(amount: 1)
    @user = Current.user
  end

  def confirm_purchase
    @buy_now = Current.user.buy_nows.build(buy_now_params.merge(
      status: :completed,
      product_id: @product.id
    ))

    if @buy_now.address_method.blank?
      flash.now[:alert] = "กรุณาเลือกที่รับสินค้า"
      render :purchase, status: :unprocessable_entity
      return
    end

    if @buy_now.payment_method == "promptpay" && params[:buy_now][:proof_of_payment].blank?
      flash.now[:alert] = "กรุณาอัพโหลดหลักฐานการชำระเงิน"
      render :purchase, status: :unprocessable_entity
      return
    end

    if @buy_now.save
      if @buy_now.payment_method == "promptpay" && params[:buy_now][:proof_of_payment].present?
        @buy_now.proof_of_payment.attach(params[:buy_now][:proof_of_payment])
      end
      redirect_to root_path, notice: "สั่งซื้อสินค้าสำเร็จ! 🎉",
      data: { testid: "buy-now-confirm-purchase-success-notice" }
    else
      flash.now[:alert] = "เกิดข้อผิดพลาดในการบันทึกข้อมูล"
      render :purchase, status: :unprocessable_entity
    end
  end

  def show
    @product = Product.find(@buy_now.product_id)
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
      redirect_to user_dashboard_path, notice: "เติมเบียร์สำเร็จ! 🍺",
      data: { testid: "buy-now-confirm-payment-success-notice" }
    else
      redirect_to qr_code_path(@buy_now), alert: "กรุณาอัปโหลดสลิปการชำระเงิน",
      data: { testid: "buy-now-confirm-payment-error-notice" }
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_buy_now
    @buy_now = Current.user.buy_nows.find(params[:id])
  end

  def buy_now_params
    params.require(:buy_now).permit(:amount, :payment_method, :address_method, :proof_of_payment, :status, :product_id)
  end
end

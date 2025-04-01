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

    # หา BuyNow ที่เป็นเครดิตเบียร์ (product_id is nil), completed, มี amount > 0, และเก่าแก่ที่สุด (FIFO)
    redeemable_buy_now = @user.buy_nows
                              .completed
                              .where(product_id: nil)
                              .where("amount > 0")
                              .order(created_at: :asc) # เรียงจากเก่าสุดไปใหม่สุด
                              .first

    if redeemable_buy_now
      # ถ้าเจอ record ที่มีเครดิตเหลือ ให้ลด amount ลง 1
      # ใช้ transaction เพื่อความปลอดภัย เผื่อมี error ระหว่าง decrement
      ActiveRecord::Base.transaction do
        redeemable_buy_now.decrement!(:amount)
        # ไม่จำเป็นต้อง save ซ้ำ เพราะ decrement! ทำการ save ให้แล้ว
      end
      redirect_to beers_path, notice: "ดื่มเบียร์สำเร็จ! เครดิตคงเหลือ #{ @user.buy_nows.completed.where(product_id: nil).sum(:amount) } แก้ว", status: :see_other,
      data: { testid: "check-out-beer-success-notice" }
    else
      # ถ้าไม่เจอ record ที่มีเครดิตเหลือ
      redirect_to beers_path, alert: "คุณไม่มีเบียร์ในคลัง", status: :see_other,
      data: { testid: "check-out-beer-error-notice" }
    end
  rescue ActiveRecord::RecordInvalid => e
    # ดักจับ error กรณี decrement ไม่สำเร็จ (อาจจะไม่เกิดกับ decrement แต่ใส่ไว้กันเหนียว)
    Rails.logger.error "Error decrementing beer credit for user #{@user.id}: #{e.message}"
    redirect_to beers_path, alert: "เกิดข้อผิดพลาดในการดื่มเบียร์", status: :see_other
  end
end

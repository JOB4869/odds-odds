class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :set_product, only: [ :add ]

  def show
  end

  def current
    render :show
  end

  def add
    begin
      @cart.add_product(@product.id)
      redirect_to product_path(@product), notice: "เพิ่มสินค้าลงตะกร้าเรียบร้อยแล้ว",
      data: { testid: "cart-add-product-success-notice" }
    rescue => e
      redirect_to product_path(@product), alert: e.message,
      data: { testid: "cart-add-product-error-notice" }
    end
  end

  def remove_item
    product_id = params[:product_id].to_i
    @cart.remove_item(product_id)
    redirect_to current_carts_path, notice: "ลบสินค้าออกจากตะกร้าเรียบร้อยแล้ว",
    data: { testid: "cart-remove-item-success-notice" }
  end

  def clear
    @cart.clear_cart
    redirect_to current_carts_path, notice: "ล้างตะกร้าเรียบร้อยแล้ว",
    data: { testid: "cart-clear-success-notice" }
  end

  def purchase_all
    @cart_items = @cart.items.select do |item|
      product = Product.find_by(id: item["product_id"])
      product && !product.sold?
    end

    if @cart_items.empty?
      redirect_to current_carts_path, alert: "ไม่มีสินค้าที่สามารถซื้อได้ในตะกร้า",
      data: { testid: "cart-purchase-all-error-notice" }
      return
    end

    @total_price = @cart_items.sum { |item| item["price"].to_f }
    @user = Current.user
  end

  def confirm_purchase_all
    product_ids = params[:cart_items]
    address_method = params[:buy_now][:address_method]
    payment_method = params[:buy_now][:payment_method]

    Rails.logger.info "Product IDs: #{product_ids.inspect}"

    if product_ids.blank?
      redirect_to current_carts_path, alert: "ไม่พบสินค้าที่ต้องการซื้อ",
      data: { testid: "cart-purchase-all-error-notice" }
      return
    end

    if address_method.blank?
      redirect_to purchase_all_carts_path, alert: "กรุณาเลือกที่รับสินค้า",
      data: { testid: "cart-purchase-all-error-notice" }
      return
    end

    if payment_method.blank?
      redirect_to purchase_all_carts_path, alert: "กรุณาเลือกวิธีการชำระเงิน",
      data: { testid: "cart-purchase-all-error-notice" }
      return
    end

    if payment_method == "promptpay" && params[:buy_now][:proof_of_payment].blank?
      redirect_to purchase_all_carts_path, alert: "กรุณาอัพโหลดหลักฐานการชำระเงิน",
      data: { testid: "cart-purchase-all-error-notice" }
      return
    end

    products = Product.where(id: product_ids)
    Rails.logger.info "Found products: #{products.map(&:id)}"

    sold_products = products.select(&:sold?)
    Rails.logger.info "Sold products: #{sold_products.map(&:id)}"

    if sold_products.any?
      redirect_to current_carts_path, alert: "มีสินค้าบางรายการถูกขายไปแล้ว กรุณาตรวจสอบและลองใหม่อีกครั้ง",
      data: { testid: "cart-purchase-all-error-notice" }
      return
    end

    ActiveRecord::Base.transaction do
      products.each do |product|
        Rails.logger.info "Processing product: #{product.id}"

        buy_now = product.buy_nows.new(
          user: Current.user,
          address_method: address_method,
          payment_method: payment_method,
          amount: 1
        )

        if params[:buy_now][:proof_of_payment].present?
          buy_now.proof_of_payment.attach(params[:buy_now][:proof_of_payment])
        end

        buy_now.save!
        Rails.logger.info "BuyNow saved for product: #{product.id}"

        product.update!(sold: true)
        Rails.logger.info "Product #{product.id} marked as sold"
      end

      remaining_items = @cart.items.reject { |item| product_ids.include?(item["product_id"].to_s) }
      @cart.update!(items: remaining_items)
      Rails.logger.info "Cart updated, remaining items: #{remaining_items.length}"
    end

    redirect_to root_path, notice: "สั่งซื้อสินค้าเรียบร้อยแล้ว",
    data: { testid: "cart-purchase-all-success-notice" }
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error in confirm_purchase_all: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to current_carts_path, alert: "เกิดข้อผิดพลาดในการสั่งซื้อ กรุณาลองใหม่อีกครั้ง",
    data: { testid: "cart-purchase-all-error-notice" }
  end

  private

  def set_cart
    @cart = Cart.find_or_create_by(user: Current.user)
  end

  def set_product
    @product = Product.find(params[:product_id])
  end
end

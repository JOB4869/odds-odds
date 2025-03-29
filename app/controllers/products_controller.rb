class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_user_profile
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Current.user.products.order(created_at: :desc)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Current.user.products.build
  end

  # GET /products/1/edit
  def edit
    unless @product.user_id == Current.user.id
      redirect_to products_path, alert: "คุณไม่มีสิทธิ์แก้ไขสินค้านี้"
    end
  end

  # POST /products or /products.json
  def create
    @product = Current.user.products.build(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to products_path, notice: "เพิ่มสินค้าเรียบร้อยแล้ว" }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    unless @product.user_id == Current.user.id
      redirect_to products_path, alert: "คุณไม่มีสิทธิ์แก้ไขสินค้านี้"
      return
    end

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to products_path, notice: "อัปเดตสินค้าเรียบร้อยแล้ว" }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    unless @product.user_id == Current.user.id
      redirect_to products_path, alert: "คุณไม่มีสิทธิ์ลบสินค้านี้"
      return
    end

    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "ลบสินค้าเรียบร้อยแล้ว" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :description, :price, images: [])
    end

    def validate_user_profile
      user = Current.user
      if user.first_name.blank? || user.last_name.blank? || user.address.blank? || user.phone.blank? || user.prompt_pay.blank?
        redirect_to accounts_path, alert: "กรุณากรอกข้อมูลบัญชีผู้ใช้ให้ครบถ้วนก่อนเข้าถึงหน้าสินค้าของฉัน"
      end
    end
end

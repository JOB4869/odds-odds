class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :edit, :update ]

  def index
    @user = Current.user
  end

  def show
    @user = Current.user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to accounts_path, notice: "บันทึกข้อมูลสำเร็จ",
      data: { testid: "account-create-success-notice" }
    else
      render :new, status: :unprocessable_entity,
      data: { testid: "account-create-error-notice" }
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(user_params)
      redirect_to accounts_path, notice: "อัปเดตข้อมูลสำเร็จ",
      data: { testid: "account-update-success-notice" }
    else
      flash.now[:alert] = "กรุณาตรวจสอบข้อมูลที่กรอก"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def user_params
    if params[:user][:password].blank?
      params.require(:user).permit(:first_name, :last_name, :address, :phone, :prompt_pay, :email)
    else
      params.require(:user).permit(:first_name, :last_name, :address, :phone, :prompt_pay, :email, :password, :password_confirmation)
    end
  end
end

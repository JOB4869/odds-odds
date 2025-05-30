class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user.present?
      PasswordMailer.with(user: @user).reset.deliver_later
      redirect_to root_path, notice: "ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว",
      data: { testid: "password-reset-create-success-notice" }
    else
      flash.now[:alert] = "ไม่พบอีเมลนี้ในระบบ"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find_signed!(params[:token], purpose: "password_reset")
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to sign_in_path, alert: "ลิงก์รีเซ็ตรหัสผ่านหมดอายุแล้ว กรุณาขอลิงก์ใหม่",
    data: { testid: "password-reset-edit-error-notice" }
  end

  def update
    @user = User.find_signed!(params[:token], purpose: "password_reset")
    if valid_password? && @user.update(password_params)
      redirect_to sign_in_path, notice: "รีเซ็ตรหัสผ่านสำเร็จ กรุณาเข้าสู่ระบบด้วยรหัสผ่านใหม่",
      data: { testid: "password-reset-update-success-notice" }
    else
      flash.now[:alert] = "รหัสผ่านไม่ถูกต้อง"
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to sign_in_path, alert: "ลิงก์รีเซ็ตรหัสผ่านหมดอายุแล้ว กรุณาขอลิงก์ใหม่",
    data: { testid: "password-reset-update-error-notice" }
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def valid_password?
    password = params[:user][:password]
    unless password.match?(/\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~])[A-Za-z\d!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~]{8,16}\z/)
      @user.errors.add(:password, "รหัสผ่านต้องมีความยาวระหว่าง 8-16 ตัวอักษร และประกอบด้วยตัวอักษร ตัวเลข และสัญลักษณ์พิเศษ")
      return false
    end
    true
  end
end

class PasswordsController < ApplicationController
  before_action :require_user_logged_in!

  def edit
  end

  def update
    if valid_password? && Current.user.update(password_params)
      redirect_to users_path, notice: "เปลี่ยนรหัสผ่านสำเร็จ",
      data: { testid: "password-update-success-notice" }
    else
      flash.now[:alert] = "รหัสผ่านไม่ถูกต้อง"
      render :edit, status: :unprocessable_entity,
      data: { testid: "password-update-error-notice" }
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def valid_password?
    password = params[:user][:password]
    unless password.match?(/\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~])[A-Za-z\d!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~]{8,16}\z/)
      Current.user.errors.add(:password, "รหัสผ่านต้องมีความยาวระหว่าง 8-16 ตัวอักษร และประกอบด้วยตัวอักษร ตัวเลข และสัญลักษณ์พิเศษ")
      return false
    end
    true
  end
end

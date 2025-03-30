class PasswordsController < ApplicationController
  before_action :require_user_logged_in!

  def edit
  end

  def update
    if Current.user.update(password_params)
      redirect_to users_path, notice: "เปลี่ยนรหัสผ่านสำเร็จ",
      data: { testid: "password-update-success-notice" }
    else
      render :edit, status: :unprocessable_entity,
      data: { testid: "password-update-error-notice" }
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

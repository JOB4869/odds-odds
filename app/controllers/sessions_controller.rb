class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user.nil?
      flash.now[:alert] = "ไม่พบอีเมลนี้ในระบบ"
      render :new, status: :unprocessable_entity
    elsif user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to stored_location_for(:user) || users_path, notice: "เข้าสู่ระบบสำเร็จ",
      data: { testid: "session-create-success-notice" }
    else
      flash.now[:alert] = "รหัสผ่านไม่ถูกต้อง"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    respond_to do |format|
      format.html { redirect_to root_path, notice: "ออกจากระบบ",
      data: { testid: "session-destroy-success-notice" } }
    end
  end

  def sign_out_modal
  end
end

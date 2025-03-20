class HomeController < ApplicationController
  def index
    if session[:user_id]
      @user = User.find(session[:user_id])
    end
    # flash[:notice] = "เข้าสู้ระบบสำเร็จ"
    # flash[:alert] = "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
  end
end

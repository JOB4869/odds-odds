class MainController < ApplicationController
  def index
    flash[:notice] = "เข้าสู้ระบบสำเร็จ"
    flash[:alert] = "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
  end
end

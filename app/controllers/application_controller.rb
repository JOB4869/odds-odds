class ApplicationController < ActionController::Base
  before_action :set_current_user

  private

  def set_current_user
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    unless Current.user
      redirect_to sign_in_path, alert: "กรุณาเข้าสู่ระบบก่อนดำเนินการต่อ"
    end
  end

  def require_user_logged_in!
    redirect_to sign_in_path, alert: "คุณต้องลงชื่อเข้าใช้เพื่อนทำสิ่งนั้น" if Current.user.nil?
  end
end

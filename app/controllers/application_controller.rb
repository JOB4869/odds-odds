class ApplicationController < ActionController::Base
  before_action :set_current_user
  private

  def set_current_user
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    unless Current.user
      store_location_for(:user, request.url)
      redirect_to sign_in_path, alert: "กรุณาเข้าสู่ระบบก่อนดำเนินการต่อ"
    end
  end

  def require_user_logged_in!
    if Current.user.nil?
      store_location_for(:user, request.url)
      redirect_to sign_in_path, alert: "คุณต้องลงชื่อเข้าใช้เพื่อนทำสิ่งนั้น"
    end
  end

  def store_location_for(resource_or_scope, location)
    session[:"#{resource_or_scope}_return_to"] = location
  end

  def stored_location_for(resource_or_scope)
    session.delete(:"#{resource_or_scope}_return_to")
  end
end

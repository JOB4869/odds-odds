class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to additional_info_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def additional_info
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

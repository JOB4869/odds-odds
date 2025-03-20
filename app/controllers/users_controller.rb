class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = Current.user
  end
end

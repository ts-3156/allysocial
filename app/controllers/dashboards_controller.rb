class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user if user_signed_in?
  end
end

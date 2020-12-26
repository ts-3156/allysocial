class DashboardsController < ApplicationController
  def show
    @user = current_user if user_signed_in?
  end
end

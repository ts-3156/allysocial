class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.user_snapshot&.data_completed?
      @user = current_user
    else
      redirect_to waiting_path
    end
  end
end

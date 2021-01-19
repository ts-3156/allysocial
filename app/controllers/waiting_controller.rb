class WaitingController < ApplicationController
  before_action :authenticate_user

  def index
    if current_user.user_snapshot&.data_completed?
      redirect_to dashboard_path
    else
      @user = current_user
    end
  end
end

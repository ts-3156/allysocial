class DashboardController < ApplicationController
  before_action :authenticate_user
  before_action :must_be_completed

  def index
  end

  private

  def must_be_completed
    redirect_to waiting_path unless current_user.user_snapshot&.data_completed?
  end
end

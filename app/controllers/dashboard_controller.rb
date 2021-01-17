class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to waiting_path unless current_user.user_snapshot&.data_completed?
    # TODO Show checkout success message
  end
end

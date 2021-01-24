class WaitingController < ApplicationController
  before_action :authenticate_user

  def index
    if current_user.user_snapshot&.data_completed?
      redirect_to dashboard_path
    else
      if ApiTooManyRequestsErrorCache.new.error_found?(current_user.id)
        @error_message = t('.rate_limit_exceeded_html', user: current_user.screen_name)
      end
    end
  end
end

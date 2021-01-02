module Api
  class JobOptionsController < BaseController
    before_action :authenticate_user!

    def index
      render json: { options: JobSelector.select_options(@user_snapshot, params[:category]) }
    end
  end
end

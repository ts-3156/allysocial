module Api
  class UrlOptionsController < BaseController
    before_action :authenticate_user!
    before_action :set_user_snapshot

    def index
      render json: { options: UrlSelector.select_options(@user_snapshot, params[:category]) }
    end
  end
end

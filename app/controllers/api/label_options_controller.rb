module Api
  class LabelOptionsController < BaseController
    before_action :authenticate_user!
    before_action :require_category
    before_action :require_type
    before_action :set_user_snapshot
    before_action :set_insight

    def index
      case params[:type]
      when 'job'
        options = JobSelector.select_options(@user_snapshot, params[:category])
      when 'location'
        options = LocationSelector.select_options(@user_snapshot, @insight)
      when 'url'
        options = UrlSelector.select_options(@user_snapshot, @insight)
      when 'keyword'
        options = KeywordSelector.select_options(@user_snapshot, @insight)
      else
        options = []
      end

      render json: { options: options }
    end
  end
end

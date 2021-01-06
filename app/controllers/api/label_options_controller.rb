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
        selector_class = JobSelector
      when 'location'
        selector_class = LocationSelector
      when 'url'
        selector_class = UrlSelector
      when 'keyword'
        selector_class = KeywordSelector
      else
        raise "Invalid type value=#{params[:type]}"
      end

      options, quick_select = selector_class.new(@user_snapshot, @insight).select_options

      render json: { options: options, quick_select: quick_select }
    end
  end
end

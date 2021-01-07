module Api
  class LabelOptionsController < BaseController
    before_action :authenticate_user!
    before_action :require_category
    before_action :require_type
    before_action :require_uid
    before_action { set_user_snapshot(params[:uid]) }
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

      render json: { options: options, quick_select: quick_select, extra: extra }
    end

    private

    def extra
      user_decorator = @user_snapshot.to_user_decorator({ category: params[:category] }, view_context)
      {
        jobs_count: user_decorator.jobs_count,
        locations_count: user_decorator.locations_count,
        urls_count: user_decorator.urls_count,
        keywords_count: user_decorator.keywords_count,
      }
    end
  end
end

module Api
  class LabelOptionsController < BaseController
    before_action :authenticate_user
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

      render json: { options: options, chart: @insight.chart_data(params[:type]), quick_select: quick_select, extra: extra }
    end

    private

    def extra
      user = @user_snapshot.to_user_decorator({ category: params[:category] }, view_context)
      {
        friends: user.friends_count,
        friends_s: user.friends_count_s,
        followers: user.followers_count,
        followers_s: user.followers_count_s,
        one_sided_friends: user.one_sided_friends_count,
        one_sided_friends_s: user.one_sided_friends_count_s,
        one_sided_followers: user.one_sided_followers_count,
        one_sided_followers_s: user.one_sided_followers_count_s,
        mutual_friends: user.mutual_friends_count,
        mutual_friends_s: user.mutual_friends_count_s,
        jobs_count: user.jobs_count,
        locations_count: user.locations_count,
        urls_count: user.urls_count,
        keywords_count: user.keywords_count,
        limit_reached: user.limit_reached?,
      }
    end
  end
end

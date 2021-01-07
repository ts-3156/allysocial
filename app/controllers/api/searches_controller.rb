module Api
  class SearchesController < BaseController
    before_action :authenticate_user!
    before_action :require_category
    before_action :require_type
    before_action :require_label
    before_action :set_user_snapshot
    before_action :set_users_snapshot

    def show
      options = { limit: params[:limit], last_uid: params[:last_uid] }
      twitter_users = @user_snapshot.search_by_users_snapshot(@users_snapshot, params[:type], params[:label], options)
      response_users = twitter_users.map { |user| user.to_user_decorator({ category: params[:category] }, view_context) }

      CreateTwitterUsersWorker.perform_async(current_user.id, twitter_users.map(&:uid))

      render json: { users: response_users }
    end

    private

    def require_label
      unless params[:label] && params[:label].match?(/\A.{1,50}\z/)
        render json: { message: ':label not specified' }, status: :bad_request
      end
    end
  end
end

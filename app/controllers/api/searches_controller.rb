module Api
  class SearchesController < BaseController
    before_action :authenticate_user!
    before_action :require_category
    before_action :require_type
    before_action :require_label
    before_action :set_user_snapshot

    def show
      twitter_users = @user_snapshot.select_users_by(params[:category], params[:type], params[:label], limit: params[:limit], last_uid: params[:last_uid])
      response_users = twitter_users.map { |user| UserDecorator.new(user.attributes, { category: params[:category] }, view_context) }

      CreateTwitterUsersWorker.perform_async(current_user.id, twitter_users.map(&:uid))

      render json: { users: response_users }
    end

    private

    def require_category
      unless params[:category] && params[:category].match?(/\A(friends|followers|one_sided_friends|one_sided_followers|mutual_friends)\z/)
        render json: { message: ':category not specified' }, status: :bad_request
      end
    end

    def require_type
      unless params[:type] && params[:type].match?(/\A(job|location|url|keyword)\z/)
        render json: { message: ':type not specified' }, status: :bad_request
      end
    end

    def require_label
      unless params[:label] && params[:label].match?(/\A.{1,50}\z/)
        render json: { message: ':label not specified' }, status: :bad_request
      end
    end
  end
end

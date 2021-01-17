module Api
  class SearchesController < BaseController
    before_action :authenticate_user!
    before_action :require_category
    before_action :require_type
    before_action :require_label
    before_action :require_uid
    before_action :require_current_size
    before_action { set_user_snapshot(params[:uid]) }

    def show
      options = {
        limit: current_limit,
        sort: params[:sort],
        filter: params[:filter],
        last_uid: params[:last_uid],
      }
      users = @user_snapshot.search_by(params[:category], params[:type], params[:label], options)

      if users.any?
        response_users = users.map { |user| user.to_user_decorator({ category: params[:category] }, view_context) }
        CreateTwitterUsersWorker.perform_async(current_user.id, users.map(&:uid))
        render json: { users: response_users }
      else
        render json: { users: [] }
      end
    end

    private

    def require_label
      unless params[:label]&.match?(/\A.{1,50}\z/)
        render json: { message: ':label not specified' }, status: :bad_request
      end
    end

    def require_current_size
      unless params[:current_size]&.match?(/\A\d{1,6}\z/)
        render json: { message: ':current_size not specified' }, status: :bad_request
      end
    end

    def total_results
      if current_user.has_subscription?(:pro)
        1_000_000
      elsif current_user.has_subscription?(:plus)
        100_000
      else
        1_000
      end
    end

    def current_limit
      current_size = params[:current_size]&.to_i || 0
      [10, (total_results - current_size).abs].min
    end
  end
end

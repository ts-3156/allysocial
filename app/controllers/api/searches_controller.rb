module Api
  class SearchesController < BaseController
    before_action :authenticate_user!
    before_action :require_category
    before_action :require_type
    before_action :require_value
    before_action :set_user_snapshot

    def show
      # TODO Limit, Offset
      users = @user_snapshot.select_users_by(params[:category], params[:type], params[:value], limit: params[:limit], last_uid: params[:last_uid])
      response_users = users.map(&:to_hash).map { |user| user_to_hash(user) }
      render json: { users: response_users }
    end

    private

    def require_category
      unless params[:category] && params[:category].match?(/\A(friends|followers)\z/)
        render json: { message: ':category not specified' }, status: :bad_request
      end
    end

    def require_type
      unless params[:type] && params[:type].match?(/\A(job|location|keyword)\z/)
        render json: { message: ':type not specified' }, status: :bad_request
      end
    end

    def require_value
      unless params[:value] && params[:value].match?(/\A.{,50}\z/)
        render json: { message: ':value not specified' }, status: :bad_request
      end
    end
  end
end

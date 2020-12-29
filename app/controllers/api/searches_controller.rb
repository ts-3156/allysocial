module Api
  class SearchesController < BaseController
    before_action :authenticate_user!
    before_action :require_category
    before_action :require_type
    before_action :require_value
    before_action :set_user_snapshot

    def show
      # TODO Limit, Offset
      users = @user_snapshot.select_users_by(params[:category], params[:type], params[:value])
      response_users = users.map(&:to_hash).map { |user| user_to_hash(user) }
      render json: { users: response_users }
    end

    private

    def require_category
      raise ':category not specified' unless params[:category] && params[:category].match?(/\A(friends|followers)\z/)
    end

    def require_type
      raise ':type not specified' unless params[:type] && params[:type].match?(/\A(job|location)\z/)
    end

    def require_value
      raise ':value not specified' unless params[:value] && params[:value].match?(/\A.{,50}\z/)
    end
  end
end

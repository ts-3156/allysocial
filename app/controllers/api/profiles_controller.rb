module Api
  class ProfilesController < BaseController
    before_action :authenticate_user!
    before_action :require_uid

    def show
      if (user_snapshot = current_user.user_snapshot) && (hash = user_snapshot.properties&.fetch('user', nil))
        user = UserDecorator.new(hash, {}, view_context)
        render json: { user: user }
      else
        render json: { message: 'Not found' }, status: :not_found
      end
    end

    private

    def require_uid
      raise ':uid not specified' unless params[:uid] && params[:uid].match?(/\A[1-9][0-9]{1,30}\z/)
    end
  end
end

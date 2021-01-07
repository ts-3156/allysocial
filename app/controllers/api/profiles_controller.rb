module Api
  class ProfilesController < BaseController
    before_action :authenticate_user!
    before_action :require_uid
    before_action :set_user_snapshot

    def show
      if (user = @user_snapshot.to_user_decorator({}, view_context))
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

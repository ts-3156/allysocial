module Api
  class ProfilesController < BaseController
    before_action :authenticate_user!
    before_action :require_uid
    before_action { set_user_snapshot(params[:uid], false) }

    def show
      user = @user_snapshot.to_user_decorator({}, view_context)
      render json: { user: user }
    end
  end
end

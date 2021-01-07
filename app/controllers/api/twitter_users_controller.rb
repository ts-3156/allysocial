module Api
  class TwitterUsersController < BaseController
    before_action :authenticate_user!

    def show
      if params[:screen_name]&.match?(/\A[\w_]{1,20}\z/)
        user = TwitterUser.find_by(screen_name: params[:screen_name])
        user = fetch_raw_user(params[:screen_name]) unless user

        if user
          render json: { user: { uid: user.uid.to_s } }
        else
          render json: { message: 'Not found' }, status: :not_found
        end
      else
        render json: { message: 'Not found' }, status: :not_found
      end
    end
  end
end

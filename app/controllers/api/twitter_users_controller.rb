module Api
  class TwitterUsersController < BaseController
    before_action :authenticate_user!
    before_action :require_screen_name

    def show
      screen_name = params[:screen_name]

      if (user = TwitterUser.find_by(screen_name: screen_name))
        render json: { user: { uid: user.uid.to_s, cache: false } }
      elsif (cache_user = ApiUserCache.new.get_by_screen_name(screen_name))
        if cache_user.error?
          render json: { message: t('.not_found', user: screen_name) }, status: :not_found
        else
          render json: { user: { uid: cache_user.uid.to_s, cache: true } }
        end
      else
        CreateTwitterUserByScreenNameWorker.perform_async(current_user.id, screen_name)
        render json: { message: t('.accepted', user: screen_name) }, status: :accepted
      end
    end

    private

    def require_screen_name
      if !params[:screen_name] || !params[:screen_name].match?(/\A[\w_]{1,20}\z/)
        render json: { message: ':screen_name not specified' }, status: :bad_request
      end
    end
  end
end

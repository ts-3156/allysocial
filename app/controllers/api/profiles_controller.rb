module Api
  class ProfilesController < BaseController
    before_action :authenticate_user!
    before_action :require_uid!

    def show
      client = current_user.api_client
      api_user = client.user(params[:uid].to_i) # TODO Call API in background

      response_user = UserSnapshot.slice_api_user(api_user)
      response_user[:description] = response_user[:description]&.gsub(/\n/, '<br>') # TODO Linkify

      render json: { user: response_user }
    end

    private

    def require_uid!
      raise ':uid not specified' unless params[:uid] && params[:uid].match?(/\A[1-9][0-9]{,30}\z/)
    end
  end
end

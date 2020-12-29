module Api
  class LocationOptionsController < BaseController
    before_action :authenticate_user!
    before_action :set_user_snapshot

    def index
      # TODO Limit users
      if params[:category] == 'friends'
        words = @user_snapshot.friends_insight.location_keywords['words'] || []
      elsif params[:category] == 'followers'
        words = @user_snapshot.followers_insight.location_keywords['words'] || []
      else
        words = []
      end

      if words.any?
        options = words.map do |word|
          { value: word, label: word.truncate(15, omission: '') }
        end

        render json: { options: options }
      else
        render json: { options: [] }
      end
    end
  end
end

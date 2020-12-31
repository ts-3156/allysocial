module Api
  class UrlOptionsController < BaseController
    before_action :authenticate_user!
    before_action :set_user_snapshot

    def index
      if params[:category] == 'friends'
        words = @user_snapshot.friends_insight.url_keywords['words'] || []
      elsif params[:category] == 'followers'
        words = @user_snapshot.followers_insight.url_keywords['words'] || []
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

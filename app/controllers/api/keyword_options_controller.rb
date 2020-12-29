module Api
  class KeywordOptionsController < BaseController
    before_action :authenticate_user!
    before_action :set_user_snapshot

    def index
      if params[:category] == 'friends'
        users = @user_snapshot.friends_snapshot&.users || []
      elsif params[:category] == 'followers'
        users = @user_snapshot.followers_snapshot&.users || []
      else
        users = []
      end

      if users.any?
        text = sanitize_descriptions(users.map(&:description)).join(' ')
        words_count = NattoClient.new.count_words(text)
        options = words_count.keys.take(100).map do |word|
          { value: word, label: word.truncate(15, omission: '') }
        end

        render json: { options: options }
      else
        render json: { options: [] }
      end
    end

    private

    def sanitize_descriptions(values)
      values.map do |value|
        strip_tags(value)
      end
    end
  end
end

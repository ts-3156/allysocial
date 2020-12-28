module Api
  class LocationOptionsController < BaseController
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
        options = sanitize_locations(users.map(&:location)).map do |location|
          { value: location, label: location.truncate(15, omission: '') }
        end

        render json: { options: options }
      else
        render json: { options: [] }
      end
    end

    private

    def sanitize_locations(values)
      values.uniq.map do |value|
        value = value.gsub(/[　\s\ufe0e]+/, ' ') if value.present?
        value = '' if value&.match?(/\A\s+\z/)
        value.blank? ? 'empty' : strip_tags(value)
      end.uniq.sort
    end
  end
end

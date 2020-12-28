class UserSnapshot < ApplicationRecord
  has_one :friends_snapshot
  has_one :followers_snapshot

  SAVE_KEYS = %i(
    uid
    name
    screen_name
    description
    friends_count
    followers_count
    profile_image_url
    profile_banner_url
  )

  def api_user_changed?(api_user)
    property_user = properties['user']

    property_user['screen_name'] != api_user[:screen_name] ||
      property_user['name'] != api_user[:name] ||
      property_user['description'] != api_user[:description] ||
      property_user['friends_count'] != api_user[:friends_count] ||
      property_user['followers_count'] != api_user[:followers_count]
  end

  class << self
    def slice_api_user(api_user)
      sliced_user = api_user.slice(*SAVE_KEYS)
      sliced_user[:uid] = api_user[:id]
      sliced_user[:profile_image_url] = sliced_user[:profile_image_url]&.remove('_normal')
      sliced_user
    end
  end
end

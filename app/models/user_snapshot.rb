class UserSnapshot < ApplicationRecord
  has_one :friends_snapshot
  has_one :followers_snapshot

  def select_users_by(category, type, value)
    if category == 'friends'
      if type == 'job'
        select_friends_by_job(value)
      elsif type == 'location'
        select_friends_by_location(value)
      else
        []
      end
    elsif category == 'followers'
      if type == 'job'
        select_followers_by_job(value)
      elsif type == 'location'
        select_followers_by_location(value)
      else
        []
      end
    else
      []
    end
  end

  def select_friends_by_job(value)
    friends_snapshot.select_users_by_job(value)
  end

  def select_friends_by_location(value)
    friends_snapshot.select_users_by_location(value)
  end

  def select_followers_by_job(value)
    followers_snapshot.select_users_by_job(value)
  end

  def select_followers_by_location(value)
    followers_snapshot.select_users_by_location(value)
  end

  SAVE_KEYS = %i(
    uid
    name
    screen_name
    description
    location
    url
    created_at
    statuses_count
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

      if api_user[:description]
        begin
          api_user[:entities][:description][:urls].each do |entity|
            sliced_user[:description].gsub!(entity[:url], entity[:expanded_url])
          end
        rescue => e
        end
      end

      if api_user[:url]
        begin
          sliced_user[:url] = api_user[:entities][:url][:urls][0][:expanded_url]
        rescue => e
        end
      end

      sliced_user
    end
  end
end

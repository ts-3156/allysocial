class UserSnapshot < ApplicationRecord
  has_one :friends_snapshot
  has_one :friends_insight
  has_one :followers_snapshot
  has_one :followers_insight

  def select_users_by(category, type, value, options)
    if category == 'friends'
      if type == 'job'
        select_friends_by_job(value, options)
      elsif type == 'location'
        select_friends_by_location(value, options)
      elsif type == 'keyword'
        select_friends_by_keyword(value, options)
      else
        []
      end
    elsif category == 'followers'
      if type == 'job'
        select_followers_by_job(value, options)
      elsif type == 'location'
        select_followers_by_location(value, options)
      elsif type == 'keyword'
        select_followers_by_keyword(value, options)
      else
        []
      end
    else
      []
    end
  end

  def select_friends_by_job(value, options)
    friends_snapshot.select_users_by_job(value, options)
  end

  def select_friends_by_location(value, options)
    friends_snapshot.select_users_by_location(value, options)
  end

  def select_friends_by_keyword(value, options)
    friends_snapshot.select_users_by_keyword(value, options)
  end

  def select_followers_by_job(value, options)
    followers_snapshot.select_users_by_job(value, options)
  end

  def select_followers_by_location(value, options)
    followers_snapshot.select_users_by_location(value, options)
  end

  def select_followers_by_keyword(value, options)
    followers_snapshot.select_users_by_keyword(value, options)
  end

  SAVE_KEYS = %i(
    uid
    screen_name
    name
    statuses_count
    friends_count
    followers_count
    description
    location
    url
    profile_image_url
    profile_banner_url
    created_at
  )

  def to_hash
    properties['user']
  end

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

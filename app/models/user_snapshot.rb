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
      elsif type == 'url'
        select_friends_by_url(value, options)
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
      elsif type == 'url'
        select_followers_by_url(value, options)
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

  def select_friends_by_url(value, options)
    friends_snapshot.select_users_by_url(value, options)
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

  def select_followers_by_url(value, options)
    followers_snapshot.select_users_by_url(value, options)
  end

  def select_followers_by_keyword(value, options)
    followers_snapshot.select_users_by_keyword(value, options)
  end
end

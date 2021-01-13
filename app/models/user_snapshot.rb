# == Schema Information
#
# Table name: user_snapshots
#
#  id         :bigint           not null, primary key
#  uid        :bigint           not null
#  properties :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserSnapshot < ApplicationRecord
  has_one :friends_snapshot
  has_one :followers_snapshot
  has_one :one_sided_friends_snapshot
  has_one :one_sided_followers_snapshot
  has_one :mutual_friends_snapshot

  has_one :friends_insight
  has_one :followers_insight
  has_one :one_sided_friends_insight
  has_one :one_sided_followers_insight
  has_one :mutual_friends_insight

  def self.latest_by(condition)
    order(created_at: :desc).find_by(condition)
  end

  def search_by(category, type, label, options)
    snapshot = fetch_snapshot(category)
    snapshot.search_by(type, label, options)
  end

  def fetch_snapshot(category)
    case category
    when 'friends'
      friends_snapshot
    when 'followers'
      followers_snapshot
    when 'one_sided_friends'
      one_sided_friends_snapshot
    when 'one_sided_followers'
      one_sided_followers_snapshot
    when 'mutual_friends'
      mutual_friends_snapshot
    else
      raise "Invalid category value=#{category}"
    end
  end

  def fetch_insight(category)
    case category
    when 'friends'
      friends_insight
    when 'followers'
      followers_insight
    when 'one_sided_friends'
      one_sided_friends_insight
    when 'one_sided_followers'
      one_sided_followers_insight
    when 'mutual_friends'
      mutual_friends_insight
    else
      raise "Invalid category value=#{category}"
    end
  end

  def data_completed?
    [
      friends_snapshot,
      followers_snapshot,
      one_sided_friends_snapshot,
      one_sided_followers_snapshot,
      mutual_friends_snapshot,
      friends_insight,
      followers_insight,
      one_sided_friends_insight,
      one_sided_followers_insight,
      mutual_friends_insight,
    ].all? { |relation| relation&.data_completed? }
  end

  def friends_count
    properties['friends_count']
  end

  def followers_count
    properties['followers_count']
  end

  UIDS_LIMIT = 5000

  def friend_uids(limit: UIDS_LIMIT)
    fetch_uids(friends_snapshot, limit)
  end

  def follower_uids(limit: UIDS_LIMIT)
    fetch_uids(followers_snapshot, limit)
  end

  def one_sided_friend_uids(limit: UIDS_LIMIT)
    fetch_uids(one_sided_friends_snapshot, limit)
  end

  def one_sided_follower_uids(limit: UIDS_LIMIT)
    fetch_uids(one_sided_followers_snapshot, limit)
  end

  def mutual_friend_uids(limit: UIDS_LIMIT)
    fetch_uids(mutual_friends_snapshot, limit)
  end

  def fetch_uids(relation, limit)
    uids = []
    relation.users_chunks.each do |chunk|
      uids.concat(chunk.uids)
      break if uids.size >= limit
    end
    uids.take(limit)
  end

  def calc_one_sided_friend_uids(limit: 100000)
    friend_uids(limit: limit) - follower_uids(limit: limit)
  end

  def calc_one_sided_follower_uids(limit: 100000)
    follower_uids(limit: limit) - friend_uids(limit: limit)
  end

  def calc_mutual_friend_uids(limit: 100000)
    friend_uids(limit: limit) & follower_uids(limit: limit)
  end

  USERS_LIMIT = 5000

  def friends(limit: USERS_LIMIT)
    fetch_users(friends_snapshot, limit)
  end

  def followers(limit: USERS_LIMIT)
    fetch_users(followers_snapshot, limit)
  end

  def one_sided_friends(limit: USERS_LIMIT)
    fetch_users(one_sided_friends_snapshot, limit)
  end

  def one_sided_followers(limit: USERS_LIMIT)
    fetch_users(one_sided_followers_snapshot, limit)
  end

  def mutual_friends(limit: USERS_LIMIT)
    fetch_users(mutual_friends_snapshot, limit)
  end

  def fetch_users(relation, limit)
    users = []
    relation.users_chunks.each do |chunk|
      uids = chunk.uids
      users.concat(TwitterUser.where(uid: uids).order_by_field(uids))
      break if users.size >= limit
    end
    users.take(limit)
  end

  def to_user_decorator(options, view_context)
    if (hash = properties.dup)
      if hash['status_created_at']
        hash['status_created_at'] = (Time.zone.parse(hash['status_created_at']) rescue nil)
      end
      UserDecorator.new(hash, { user_snapshot: self }.merge(options), view_context)
    end
  end
end

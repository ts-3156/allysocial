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

  def search_by(category, type, label, options)
    raise "Invalid label value=#{label}" if label.blank?

    case category
    when 'friends'
      snapshot = friends_snapshot
    when 'followers'
      snapshot = followers_snapshot
    when 'one_sided_friends'
      snapshot = one_sided_friends_snapshot
    when 'one_sided_followers'
      snapshot = one_sided_followers_snapshot
    when 'mutual_friends'
      snapshot = mutual_friends_snapshot
    else
      raise "Invalid category value=#{category}"
    end

    search_by_snapshot(snapshot, type, label, options)
  end

  def search_by_snapshot(snapshot, type, label, options)
    case type
    when 'job'
      snapshot.search_by_job(label, options)
    when 'location'
      snapshot.search_by_location(label, options)
    when 'url'
      snapshot.search_by_url(label, options)
    when 'keyword'
      snapshot.search_by_keyword(label, options)
    else
      raise "Invalid type value=#{type}"
    end
  end

  def data_completed?
    # TODO
    friends_snapshot&.data_completed? && followers_snapshot&.data_completed? && friends_insight&.data_completed? && followers_insight&.data_completed?
  end

  def friend_uids
    friends_snapshot.users_chunks.map { |chunk| chunk.properties['uids'] }.flatten
  end

  def follower_uids
    followers_snapshot.users_chunks.map { |chunk| chunk.properties['uids'] }.flatten
  end

  def one_sided_friend_uids
    one_sided_friends_snapshot.users_chunks.map { |chunk| chunk.properties['uids'] }.flatten
  end

  def one_sided_follower_uids
    one_sided_followers_snapshot.users_chunks.map { |chunk| chunk.properties['uids'] }.flatten
  end

  def mutual_friend_uids
    mutual_friends_snapshot.users_chunks.map { |chunk| chunk.properties['uids'] }.flatten
  end

  def friends
    friends_snapshot.users_chunks.map do |chunk|
      uids = chunk.properties['uids']
      TwitterUser.where(uid: uids).order_by_field(uids)
    end.flatten
  end

  def followers
    followers_snapshot.users_chunks.map do |res|
      uids = res.properties['uids']
      TwitterUser.where(uid: uids).order_by_field(uids)
    end.flatten
  end

  def one_sided_friends
    one_sided_friends_snapshot.users_chunks.map do |chunk|
      uids = chunk.properties['uids']
      TwitterUser.where(uid: uids).order_by_field(uids)
    end.flatten
  end

  def one_sided_followers
    one_sided_followers_snapshot.users_chunks.map do |chunk|
      uids = chunk.properties['uids']
      TwitterUser.where(uid: uids).order_by_field(uids)
    end.flatten
  end

  def mutual_friends
    mutual_friends_snapshot.users_chunks.map do |chunk|
      uids = chunk.properties['uids']
      TwitterUser.where(uid: uids).order_by_field(uids)
    end.flatten
  end
end

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

  def select_users_by(category, type, label, options)
    return [] if label.blank?

    if category == 'friends'
      if type == 'job'
        select_friends_by_job(label, options)
      elsif type == 'location'
        select_friends_by_location(label, options)
      elsif type == 'url'
        select_friends_by_url(label, options)
      elsif type == 'keyword'
        select_friends_by_keyword(label, options)
      else
        []
      end
    elsif category == 'followers'
      if type == 'job'
        select_followers_by_job(label, options)
      elsif type == 'location'
        select_followers_by_location(label, options)
      elsif type == 'url'
        select_followers_by_url(label, options)
      elsif type == 'keyword'
        select_followers_by_keyword(label, options)
      else
        []
      end
    else
      []
    end
  end

  def select_friends_by_job(label, options)
    friends_snapshot.select_users_by_job(label, options)
  end

  def select_friends_by_location(label, options)
    friends_snapshot.select_users_by_location(label, options)
  end

  def select_friends_by_url(label, options)
    friends_snapshot.select_users_by_url(label, options)
  end

  def select_friends_by_keyword(label, options)
    friends_snapshot.select_users_by_keyword(label, options)
  end

  def select_followers_by_job(label, options)
    followers_snapshot.select_users_by_job(label, options)
  end

  def select_followers_by_location(label, options)
    followers_snapshot.select_users_by_location(label, options)
  end

  def select_followers_by_url(label, options)
    followers_snapshot.select_users_by_url(label, options)
  end

  def select_followers_by_keyword(label, options)
    followers_snapshot.select_users_by_keyword(label, options)
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

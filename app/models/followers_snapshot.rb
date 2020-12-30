class FollowersSnapshot < ApplicationRecord
  include SnapshotImplementation

  belongs_to :user_snapshot
  has_many :followers_responses

  def api_responses
    followers_responses
  end

  def uids
    api_responses.map { |res| res.properties['uids'] }.flatten
  end

  def users
    TwitterUser.where(uid: uids).order_by_field(uids)
  end
end

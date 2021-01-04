class MutualFriendsSnapshot < ApplicationRecord
  include SnapshotImplementation

  belongs_to :user_snapshot
  has_many :mutual_friends_chunks

  def users_chunks
    mutual_friends_chunks
  end

  def update_from_user_snapshot(user_id, user_snapshot)
    insight_enqueued = false

    friend_uids = user_snapshot.friends_snapshot.users_chunks.map { |chunk| chunk.properties['uids'] }.flatten
    follower_uids = user_snapshot.followers_snapshot.users_chunks.map { |chunk| chunk.properties['uids'] }.flatten

    (friend_uids & follower_uids).each_slice(5000).each do |uids_array|
      users_chunks.create!(properties: { uids: uids_array })

      unless insight_enqueued
        insight_enqueued = true
        # TODO
      end
    end

    update(completed_at: Time.zone.now)
  end
end

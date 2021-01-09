# == Schema Information
#
# Table name: followers_snapshots
#
#  id               :bigint           not null, primary key
#  user_snapshot_id :bigint           not null
#  completed_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class FollowersSnapshot < ApplicationRecord
  include SearchImplementation

  belongs_to :user_snapshot
  has_many :followers_chunks

  def users_chunks
    followers_chunks
  end

  def update_from_user_id(user_id)
    insight_enqueued = false
    client = User.find(user_id).api_client

    client.follower_ids(user_snapshot.uid) do |response|
      attrs = response.attrs
      users_chunks.create!(previous_cursor: attrs[:previous_cursor], next_cursor: attrs[:next_cursor], properties: { uids: attrs[:ids] })

      attrs[:ids].each_slice(100) do |uids_array|
        CreateTwitterUsersWorker.perform_async(user_id, uids_array)
      end

      unless insight_enqueued
        insight_enqueued = true
        CreateFollowersInsightWorker.perform_async(user_id, user_snapshot.id, attrs[:ids].take(5000))
      end
    end

    update(completed_at: Time.zone.now)
  end

end

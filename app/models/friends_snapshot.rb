# == Schema Information
#
# Table name: friends_snapshots
#
#  id               :bigint           not null, primary key
#  user_snapshot_id :bigint           not null
#  properties       :json
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class FriendsSnapshot < ApplicationRecord
  include SnapshotImplementation

  belongs_to :user_snapshot
  has_many :friends_responses

  def api_responses
    friends_responses
  end

  def update_from_user_id(user_id)
    insight_enqueued = false
    client = User.find(user_id).api_client

    client.friend_ids(user_snapshot.uid) do |response|
      attrs = response.attrs
      api_responses.create!(previous_cursor: attrs[:previous_cursor], next_cursor: attrs[:next_cursor], properties: { uids: attrs[:ids] })

      attrs[:ids].each_slice(100) do |uids_array|
        CreateTwitterUsersWorker.perform_async(user_id, uids_array)
      end

      unless insight_enqueued
        insight_enqueued = true
        CreateFriendsInsightWorker.perform_async(user_id, user_snapshot.id, attrs[:ids].take(5000))
      end
    end

    update(completed_at: Time.zone.now)
  end
end

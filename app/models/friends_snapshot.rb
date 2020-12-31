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
end

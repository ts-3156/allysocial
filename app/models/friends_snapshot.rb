# == Schema Information
#
# Table name: friends_snapshots
#
#  id               :bigint           not null, primary key
#  user_snapshot_id :bigint           not null
#  completed_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class FriendsSnapshot < ApplicationRecord
  include SnapshotImplementation
  include SearchImplementation

  belongs_to :user_snapshot
  has_many :friends_chunks

  def users_chunks
    friends_chunks
  end

  def update_from_user_id(user_id)
    super(user_id, user_snapshot.properties['friends_count'], :friend_ids)
  end
end

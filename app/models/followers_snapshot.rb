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
  include Completable
  include SnapshotImplementation
  include SearchImplementation

  belongs_to :user_snapshot
  has_many :followers_chunks

  def users_chunks
    followers_chunks
  end

  def update_from_user_id(user_id)
    super(user_id, user_snapshot.followers_count, :follower_ids)
  end
end

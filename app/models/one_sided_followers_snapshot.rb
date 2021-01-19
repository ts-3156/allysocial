# == Schema Information
#
# Table name: one_sided_followers_snapshots
#
#  id               :bigint           not null, primary key
#  user_snapshot_id :bigint           not null
#  completed_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class OneSidedFollowersSnapshot < ApplicationRecord
  include Completable
  include SearchImplementation

  belongs_to :user_snapshot
  has_many :one_sided_followers_chunks

  def users_chunks
    one_sided_followers_chunks
  end

  def update_from_user_snapshot(user_id, user_snapshot)
    user_snapshot.calc_one_sided_follower_uids.each_slice(5000).each do |uids|
      users_chunks.create!(uids: uids)
    end

    update(completed_at: Time.zone.now)
  end
end

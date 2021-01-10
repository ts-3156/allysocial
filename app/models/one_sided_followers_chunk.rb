# == Schema Information
#
# Table name: one_sided_followers_chunks
#
#  id                              :bigint           not null, primary key
#  one_sided_followers_snapshot_id :bigint           not null
#  uids                            :json
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
class OneSidedFollowersChunk < ApplicationRecord
  belongs_to :one_sided_followers_snapshot
end

# == Schema Information
#
# Table name: one_sided_friends_chunks
#
#  id                            :bigint           not null, primary key
#  one_sided_friends_snapshot_id :bigint           not null
#  properties                    :json
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class OneSidedFriendsChunk < ApplicationRecord
  belongs_to :one_sided_friends_snapshot
end

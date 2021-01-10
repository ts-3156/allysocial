# == Schema Information
#
# Table name: friends_chunks
#
#  id                  :bigint           not null, primary key
#  friends_snapshot_id :bigint           not null
#  previous_cursor     :bigint
#  next_cursor         :bigint
#  uids                :json
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class FriendsChunk < ApplicationRecord
  belongs_to :friends_snapshot
end

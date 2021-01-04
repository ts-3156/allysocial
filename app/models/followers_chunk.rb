# == Schema Information
#
# Table name: followers_chunks
#
#  id                    :bigint           not null, primary key
#  followers_snapshot_id :bigint           not null
#  previous_cursor       :bigint
#  next_cursor           :bigint
#  properties            :json
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class FollowersChunk < ApplicationRecord
  belongs_to :followers_snapshot
end

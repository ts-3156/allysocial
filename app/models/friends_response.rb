# == Schema Information
#
# Table name: friends_responses
#
#  id                  :bigint           not null, primary key
#  friends_snapshot_id :bigint           not null
#  previous_cursor     :bigint
#  next_cursor         :bigint
#  properties          :json
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class FriendsResponse < ApplicationRecord
  belongs_to :friends_snapshot
end

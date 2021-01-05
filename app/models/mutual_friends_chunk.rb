# == Schema Information
#
# Table name: mutual_friends_chunks
#
#  id                         :bigint           not null, primary key
#  mutual_friends_snapshot_id :bigint           not null
#  properties                 :json
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
class MutualFriendsChunk < ApplicationRecord
  belongs_to :mutual_friends_snapshot
end

# == Schema Information
#
# Table name: mutual_friends_insights
#
#  id               :bigint           not null, primary key
#  user_snapshot_id :bigint           not null
#  description      :json
#  location         :json
#  url              :json
#  completed_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class MutualFriendsInsight < ApplicationRecord
  include InsightImplementation

  belongs_to :user_snapshot
end

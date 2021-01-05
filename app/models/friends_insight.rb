# == Schema Information
#
# Table name: friends_insights
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
class FriendsInsight < ApplicationRecord
  include InsightImplementation

  belongs_to :user_snapshot
end

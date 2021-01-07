# == Schema Information
#
# Table name: one_sided_followers_insights
#
#  id               :bigint           not null, primary key
#  user_snapshot_id :bigint           not null
#  users_count      :integer
#  job              :json
#  description      :json
#  location         :json
#  url              :json
#  completed_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class OneSidedFollowersInsight < ApplicationRecord
  include InsightImplementation

  belongs_to :user_snapshot
end

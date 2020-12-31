# == Schema Information
#
# Table name: followers_insights
#
#  id                   :bigint           not null, primary key
#  user_snapshot_id     :bigint           not null
#  description_keywords :json
#  location_keywords    :json
#  url_keywords         :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class FollowersInsight < ApplicationRecord
  include InsightImplementation

  belongs_to :user_snapshot
end

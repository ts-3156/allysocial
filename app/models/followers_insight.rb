class FollowersInsight < ApplicationRecord
  include InsightImplementation

  belongs_to :user_snapshot
end

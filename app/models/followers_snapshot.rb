class FollowersSnapshot < ApplicationRecord
  include Searchable

  belongs_to :user_snapshot
  has_many :followers_responses

  def api_responses
    followers_responses
  end
end

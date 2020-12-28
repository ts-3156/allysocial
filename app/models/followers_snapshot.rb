class FollowersSnapshot < ApplicationRecord
  include Searchable

  belongs_to :user_snapshot
end

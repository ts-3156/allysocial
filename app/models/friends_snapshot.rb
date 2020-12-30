class FriendsSnapshot < ApplicationRecord
  include SnapshotImplementation

  belongs_to :user_snapshot
  has_many :friends_responses

  def api_responses
    friends_responses
  end
end

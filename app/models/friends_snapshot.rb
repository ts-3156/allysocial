class FriendsSnapshot < ApplicationRecord
  include Searchable

  belongs_to :user_snapshot
  has_many :friends_responses

  def api_responses
    friends_responses
  end
end

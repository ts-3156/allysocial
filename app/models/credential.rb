class Credential < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true
  validates :access_token, presence: true
  validates :access_secret, presence: true
end

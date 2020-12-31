# == Schema Information
#
# Table name: credentials
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  authorized    :boolean          not null
#  access_token  :text(65535)      not null
#  access_secret :text(65535)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Credential < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true
  validates :access_token, presence: true
  validates :access_secret, presence: true
end

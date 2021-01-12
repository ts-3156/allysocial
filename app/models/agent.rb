# == Schema Information
#
# Table name: agents
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Agent < ApplicationRecord
  belongs_to :user

  class << self
    def api_client
      find(pluck(:id).sample).user.api_client
    end
  end
end

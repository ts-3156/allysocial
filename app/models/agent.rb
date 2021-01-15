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

  def api_client
    user.api_client
  end

  class << self
    def api_client
      find(pluck(:id).sample).api_client
    end

    def dump
      all.map do |agent|
        user = agent.user
        credential = user.credential
        [user.uid, user.screen_name, credential.access_token, credential.access_secret].join(',')
      end.join("\n")
    end
  end
end

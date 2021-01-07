require 'active_support/concern'

module HasOccupation
  extend ActiveSupport::Concern

  class_methods do
  end

  def occupation
    Occupation.new(
      name: name,
      description: description,
      url: url,
      location: location,
      friends_count: friends_count,
      followers_count: followers_count,
    )
  end
end

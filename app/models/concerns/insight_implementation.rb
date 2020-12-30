require 'active_support/concern'

module InsightImplementation
  extend ActiveSupport::Concern

  class_methods do
  end

  def update_description_from_users(users)
    words = extract_description_keywords(users)
    update!(description_keywords: { words: words })
  end

  def update_location_from_users(users)
    words = extract_location_keywords(users)
    update!(location_keywords: { words: words })
  end

  private

  def extract_description_keywords(users)
    text = users.take(1000).map(&:description).join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text).keys.take(500)
  end

  def extract_location_keywords(users)
    text = users.take(5000).map { |u| u.location.split(/[、。, .←→・\/]/) }.flatten.join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text).keys.take(500)
  end
end

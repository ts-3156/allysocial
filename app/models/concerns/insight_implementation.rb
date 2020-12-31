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

  def update_url_from_users(users)
    words = extract_url_keywords(users)
    update!(url_keywords: { words: words })
  end

  private

  def extract_description_keywords(users)
    text = users.take(1000).map(&:description).join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text).keys.take(500)
  end

  def extract_location_keywords(users)
    text = users.take(5000).map(&:location).compact.map { |location| location.split(/[、。, .←→・\/]/) }.flatten.join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text).keys.take(500)
  end

  def extract_url_keywords(users)
    text = users.take(5000).map(&:url).compact.map do |url|
      uri = URI.parse(url)
      uri = URI.parse("http://#{url}") if uri.scheme.nil?
      host = uri.host.downcase
      host.remove!(/\Awww\./)
      host.split('.')
    rescue => e
      ''
    end.flatten.join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text, min_word_length: 4).keys.take(500)
  end
end

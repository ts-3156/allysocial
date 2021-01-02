require 'active_support/concern'

module InsightImplementation
  extend ActiveSupport::Concern

  class_methods do
  end

  def update_from_uids(user_id, uids)
    limit = 5000 # TODO Set suitable limit
    uids = uids.take(limit)

    twitter_users, not_persisted_uids = fetch_persisted_users(uids)

    if not_persisted_uids.any?
      twitter_users.concat(fetch_missing_users(user_id, not_persisted_uids))
    end

    users = twitter_users.sort_by { |user| uids.index(user.uid) || limit }

    update_description_from_users(users)
    update_location_from_users(users)
    update_url_from_users(users)

    update(completed_at: Time.zone.now)
  end

  def fetch_persisted_users(uids)
    return_users = []
    not_persisted_uids = []

    uids.each_slice(100) do |uids_array|
      users = TwitterUser.where(uid: uids_array)
      not_persisted_uids.concat(uids_array - users.map(&:uid))
      return_users.concat(users)
    end

    [return_users, not_persisted_uids]
  end

  def fetch_missing_users(user_id, uids)
    client = User.find(user_id).api_client
    return_users = []

    uids.each_slice(100) do |uids_array|
      users = client.users(uids_array).map { |user| ApiUser.new(user) }
      return_users.concat(users)
    rescue => e
      logger.warn "Fetching users failed #{e.inspect}"
      logger.warn e.backtrace.join("\n")
    end

    return_users
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

  def data_completed?
    completed_at.present?
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

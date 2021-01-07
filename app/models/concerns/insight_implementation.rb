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
    update_from_users(users)
  end

  def update_from_users(users)
    update_job_from_users(users)
    update_description_from_users(users)
    update_location_from_users(users)
    update_url_from_users(users)

    update(users_count: users.size, completed_at: Time.zone.now)
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
      logger.warn "Failed to fetch missing users exception=#{e.inspect}"
      logger.warn e.backtrace.join("\n")
    end

    return_users
  end

  def update_job_from_users(users)
    words_count = extract_job_keywords(users)
    update!(job: { words_count: words_count })
  end

  def update_description_from_users(users)
    words_count = extract_description_keywords(users)
    update!(description: { words_count: words_count })
  end

  def update_location_from_users(users)
    words_count = extract_location_keywords(users)
    update!(location: { words_count: words_count })
  end

  def update_url_from_users(users)
    words_count = extract_url_keywords(users)
    update!(url: { words_count: words_count })
  end

  def job_words
    job['words_count'].take(500)
  end

  def description_words
    description['words_count'].take(500)
  end

  def location_words
    location['words_count'].take(500)
  end

  def url_words
    url['words_count'].take(500)
  end

  def data_completed?
    completed_at.present?
  end

  private

  def extract_job_keywords(users)
    users = users.take(5000) # TODO Set suitable limit
    words = []
    users.map(&:occupation).each do |occupation|
      words << occupation.detect_title
    end
    words.each_with_object(Hash.new(0)) do |word, memo|
      memo[word] += 1
    end.sort_by { |_, c| -c }.take(500)
  end

  MEANINGLESS_REGEXP = /\A(com|the|in|of|and|to|jp|is|on|at|my|this|with|\d{2}%?|\d{4}年?)\z/

  def extract_description_keywords(users)
    text = users.take(1000).map(&:description).join(' ') # TODO Set suitable limit
    words = NattoClient.new.count_words(text).take(500)
    words.reject! do |word, _|
      word.downcase.match?(MEANINGLESS_REGEXP)
    end
    words
  end

  JAPAN_REGEXP = /japan|nihon|nippon|日本|にほん/
  KANTO_REGEXP = /kanto|関東|かんとう/
  TOKYO_REGEXP = /tokyo|東京都?|とうきょうと?/
  OSAKA_REGEXP = /osaka|大阪府?|おおさかふ?/
  KYOTO_REGEXP = /kyoto|京都府?|きょうとふ?/

  def extract_location_keywords(users)
    text = users.take(5000).map(&:location).compact.map do |location|
      location.downcase.split(/[、。, .←→・\/]/)
    rescue => e
      ''
    end.flatten.join(' ') # TODO Set suitable limit
    text.gsub!(JAPAN_REGEXP, ' Japan ')
    text.gsub!(KANTO_REGEXP, ' Kanto ')
    text.gsub!(TOKYO_REGEXP, ' Tokyo ')
    text.gsub!(OSAKA_REGEXP, ' Osaka ')
    text.gsub!(KYOTO_REGEXP, ' Kyoto ')
    words = NattoClient.new.count_words(text).take(500)
    words.reject! do |word, _|
      word.match?(MEANINGLESS_REGEXP) ||
        word.match?(/\A(\(\(|-?\d+)\z/)
    end
    words
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
    NattoClient.new.count_words(text, min_word_length: 4).take(500)
  end
end

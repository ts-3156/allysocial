require 'active_support/concern'

module InsightImplementation
  extend ActiveSupport::Concern

  class_methods do
  end

  def update_from_uids(user_id, uids)
    limit = 5000 # TODO Set suitable limit
    limited_uids = uids.take(limit)

    twitter_users, not_persisted_uids = fetch_persisted_users(limited_uids)

    if not_persisted_uids.any?
      twitter_users.concat(fetch_missing_users(user_id, not_persisted_uids))
    end

    users = twitter_users.sort_by { |user| limited_uids.index(user.uid) || limit }
    update_from_users(users)
    update(completed_at: Time.zone.now)
  end

  def update_from_users(users)
    update_job_from_users(users)
    update_description_from_users(users)
    update_location_from_users(users)
    update_url_from_users(users)
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
      if TwitterApiStatus.no_user_matches?(e)
        # Do nothing
      else
        logger.warn "Failed to fetch missing users exception=#{e.inspect}"
        logger.warn e.backtrace.join("\n")
      end
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

  def job_words(limit: 500)
    job['words_count'].take(limit)
  end

  def description_words(limit: 500)
    description['words_count'].take(limit)
  end

  def location_words(limit: 500)
    location['words_count'].take(limit)
  end

  def url_words(limit: 500)
    url['words_count'].take(limit)
  end

  def chart_data(type)
    case type
    when 'job'
      generate_chart_data(job_words(limit: 10), type)
    when 'location'
      generate_chart_data(location_words(limit: 10))
    when 'url'
      generate_chart_data(url_words(limit: 10))
    when 'keyword'
      generate_chart_data(description_words(limit: 10))
    else
      raise "Invalid type value=#{type}"
    end
  end

  def generate_chart_data(words, type = nil)
    categories = []
    series = []

    words.each do |word, count|
      categories << (type == 'job' ? JobSelector.value_to_label(word) : word)
      series << count
    end

    { categories: categories, series: series }
  end

  def data_completed?
    completed_at.present?
  end

  private

  def extract_job_keywords(users)
    users = users.take(5000) # TODO Set suitable limit
    words = []
    users.map(&:occupation).each do |occupation|
      words.concat(occupation.job_keys)
    end
    words = words.each_with_object(Hash.new(0)) do |word, memo|
      memo[word] += 1
    end.sort_by { |_, c| -c }.take(500)

    if (index = words.index { |w, _| w == 'not_applicable' })
      words.push(words.delete_at(index))
    end

    words
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

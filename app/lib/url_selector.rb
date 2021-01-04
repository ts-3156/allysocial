class UrlSelector
  VALUES = %w(
    instagram
    tiktok
    youtube
  )

  LABELS = {
    en: {
      instagram: 'Instagram',
      tiktok: 'TikTok',
      youtube: 'YouTube',
    },
    ja: {
      instagram: 'Instagram',
      tiktok: 'TikTok',
      youtube: 'YouTube',
    }
  }

  class << self
    def select_options(user_snapshot, category)
      labels = LABELS[I18n.locale]
      options = VALUES.map do |value|
        { value: labels[value.to_sym], label: labels[value.to_sym] }
      end

      if category == 'friends'
        words = user_snapshot.friends_insight.url_words || []
      elsif category == 'followers'
        words = user_snapshot.followers_insight.url_words || []
      else
        words = []
      end

      if words.any?
        options << { value: '--------', label: '--------' }
        words.each do |word|
          options << { value: word, label: word.truncate(15, omission: '') }
        end
      end

      options
    end

    def matched_value(value)
      LABELS[:en].find { |_, label| label == value }&.first ||
        LABELS[:ja].find { |_, label| label == value }&.first
    end
  end
end

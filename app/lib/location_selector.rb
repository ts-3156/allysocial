class LocationSelector
  VALUES = %w(
    japan
    kanto
    tokyo
  )

  LABELS = {
    en: {
      japan: 'Japan',
      kanto: 'Japan > Kanto',
      tokyo: 'Japan > Kanto > Tokyo',
    },
    ja: {
      japan: '日本',
      kanto: '日本 > 関東',
      tokyo: '日本 > 関東 > 東京',
    }
  }

  class << self
    def select_options(user_snapshot, insight)
      labels = LABELS[I18n.locale]
      options = VALUES.map do |value|
        { value: labels[value.to_sym], label: labels[value.to_sym] }
      end

      words = insight.location_words || []

      if words.any?
        options << { value: '--------', label: '--------' }
        words.each do |word, count|
          word = "#{word.truncate(15, omission: '')} (#{count})"
          options << { value: word, label: word }
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

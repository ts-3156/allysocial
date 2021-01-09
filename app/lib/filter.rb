class Filter
  VALUES = %w(
    active
    inactive_2weeks
 )

  TRANSLATIONS = {
    en: {
      active: 'Active',
      inactive_2weeks: 'No tweets for 2 weeks',
    },
    ja: {
      active: 'アクティブ',
      inactive_2weeks: '2週間ツイート無し',
    }
  }

  class << self
    def value_to_label(raw_key)
      TRANSLATIONS[I18n.locale].each do |key, label|
        return label if raw_key.to_sym == key
      end
      nil
    end

    def apply(query, value)
      case value
      when VALUES[0]
        query.where('status_created_at > ?', 2.weeks.ago)
      when VALUES[1]
        query.where('status_created_at < ?', 2.weeks.ago)
      else
        query
      end
    end
  end
end

class Sort
  VALUES = %w(
    asc
    desc
 )

  TRANSLATIONS = {
    en: {
      asc: 'The most recent first',
      desc: 'The most ancient first',
    },
    ja: {
      asc: '新しい順',
      desc: '古い順',
    }
  }

  class << self
    def value_to_label(raw_key)
      TRANSLATIONS[I18n.locale].each do |key, label|
        return label if raw_key.to_sym == key
      end
      nil
    end
  end
end

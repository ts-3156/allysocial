class LocationSelector < BaseSelector
  class << self
    def fixed_values
      %w(
        japan
        kanto
        tokyo
      )
    end

    def fixed_labels
      {
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
    end
  end

  def select_options
    extracted_options = options_from_words(@insight.location_words)
    quick_select = extracted_options.take(3)
    [extracted_options, quick_select]
  end
end

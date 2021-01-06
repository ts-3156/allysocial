class UrlSelector < BaseSelector
  def fixed_values
    %w(
        instagram
        tiktok
        youtube
      )
  end

  def fixed_labels
    {
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
  end

  def select_options
    extracted_options = options_from_words(@insight.url_words)
    quick_select = extracted_options.take(3)
    [extracted_options, quick_select]
  end
end

class KeywordSelector < BaseSelector
  class << self
    def fixed_values
      %w(
        accepting_requests_for_work
      )
    end

    def fixed_labels
      {
        en: {
          accepting_requests_for_work: 'Accepting requests for work',
        },
        ja: {
          accepting_requests_for_work: 'お仕事募集中',
        }
      }
    end
  end

  def select_options
    extracted_options = options_from_words(@insight.description_words)
    quick_select = extracted_options.take(3)
    options = fixed_options + [divider] + extracted_options
    [options, quick_select]
  end
end

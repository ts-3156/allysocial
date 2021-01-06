class BaseSelector
  def initialize(user_snapshot, insight)
    @user_snapshot = user_snapshot
    @insight = insight
  end

  def fixed_options
    labels = fixed_labels[I18n.locale]
    fixed_values.map do |value|
      { value: labels[value.to_sym], label: labels[value.to_sym] }
    end
  end

  def options_from_words(words)
    return [] if words.blank?

    words.map do |word, count|
      label = "#{word.truncate(15, omission: '')} (#{count})"
      { value: word, label: label }
    end
  end

  def divider
    { value: '--------', label: '--------' }
  end

  def fixed_values
    self.class.fixed_values
  end

  def fixed_labels
    self.class.fixed_labels
  end

  class << self
    def matched_value(value)
      fixed_labels[:en].find { |_, label| label == value }&.first ||
        fixed_labels[:ja].find { |_, label| label == value }&.first
    end
  end
end

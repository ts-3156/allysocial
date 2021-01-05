class UserDecorator
  def initialize(attrs, options, view_context)
    @attrs = attrs.symbolize_keys
    @options = options
    @view_context = view_context
  end

  def location
    if @attrs[:location].blank? || @attrs[:location].match?(/\A\s+\z/)
      'none'
    else
      @attrs[:location].truncate(30)
    end
  end

  def url
    if @attrs[:url].blank? || @attrs[:url].match?(/\A\s+\z/)
      '#'
    else
      @attrs[:url]
    end
  end

  def url_s
    if @attrs[:url].blank? || @attrs[:url].match?(/\A\s+\z/)
      'none'
    else
      if @attrs[:url].match?(/(\Ahttps?:\/\/)|(\/\z)/)
        @attrs[:url].remove(/(\Ahttps?:\/\/)|(\/\z)/).truncate(30)
      else
        @attrs[:url]
      end
    end
  end

  def followers_label()
    if @options[:category] == 'followers'
      category_label(I18n.t('templates.search_response_user_template.categories.follower'))
    end
  end

  def one_sided_friends_label
    if @options[:category] == 'one_sided_friends'
      category_label(I18n.t('templates.search_response_user_template.categories.one_sided_friend'))
    end
  end

  def one_sided_followers_label
    if @options[:category] == 'one_sided_followers'
      category_label(I18n.t('templates.search_response_user_template.categories.one_sided_follower'))
    end
  end

  def mutual_friends_label
    if @options[:category] == 'mutual_friends'
      category_label(I18n.t('templates.search_response_user_template.categories.mutual_friend'))
    end
  end

  def category_label(text)
    %Q(<span class="badge badge-secondary" style="background-color: darkgray;">#{text}</span>)
  end

  def active_period?(duration)
    @attrs[:status_created_at] >= duration.ago
  rescue => e
    false
  end

  def inactive_period?(duration)
    @attrs[:status_created_at] < duration.ago
  rescue => e
    false
  end

  def active_1hour_label
    if active_period?(1.hour)
      active_label(I18n.t('templates.search_response_user_template.active_1hour'))
    end
  end

  def active_12hours_label
    if active_period?(12.hours)
      active_label(I18n.t('templates.search_response_user_template.active_12hours'))
    end
  end

  def active_3days_label
    if active_period?(3.days)
      active_label(I18n.t('templates.search_response_user_template.active_3days'))
    end
  end

  def active_1week_label
    if active_period?(1.week)
      active_label(I18n.t('templates.search_response_user_template.active_1week'))
    end
  end

  def active_label(text)
    %Q(<span class="badge badge-primary">#{text}</span>)
  end

  def inactive_3months_label
    if inactive_period?(3.months)
      inactive_label(I18n.t('templates.search_response_user_template.inactive_3months'))
    end
  end

  def inactive_1month_label
    if inactive_period?(1.month)
      inactive_label(I18n.t('templates.search_response_user_template.inactive_1month'))
    end
  end

  def inactive_1week_label
    if inactive_period?(1.week)
      inactive_label(I18n.t('templates.search_response_user_template.inactive_1week'))
    end
  end

  def inactive_label(text)
    %Q(<span class="badge badge-secondary" style="background-color: darkgray;">#{text}</span>)
  end

  def labels
    [
      mutual_friends_label || one_sided_followers_label || one_sided_friends_label || followers_label,
      active_1hour_label || active_12hours_label || active_3days_label || active_1week_label || inactive_3months_label || inactive_1month_label || inactive_1week_label,
    ].compact.join('&nbsp;')
  end

  def to_hash
    {
      uid: @attrs[:uid].to_s,
      screen_name: @attrs[:screen_name],
      name: @attrs[:name],
      statuses_count: @attrs[:statuses_count],
      statuses_count_s: (@attrs[:statuses_count].to_s(:delimited) rescue nil),
      friends_count: @attrs[:friends_count],
      friends_count_s: (@attrs[:friends_count].to_s(:delimited) rescue nil),
      followers_count: @attrs[:followers_count],
      followers_count_s: (@attrs[:followers_count].to_s(:delimited) rescue nil),
      description: @view_context.strip_tags(@attrs[:description]),
      location: location,
      url: url,
      url_s: url_s,
      profile_image_url: @attrs[:profile_image_url],
      profile_banner_url: @attrs[:profile_banner_url],
      account_created_at: @attrs[:account_created_at],
      status_block: @attrs[:status_id] ? 'block' : 'none',
      status_id: @attrs[:status_id]&.to_s,
      status_text: @attrs[:status_text],
      status_retweet_count: @attrs[:status_retweet_count],
      status_retweet_count_s: (@attrs[:status_retweet_count].to_s(:delimited) rescue nil),
      status_favorite_count: @attrs[:status_favorite_count],
      status_favorite_count_s: (@attrs[:status_favorite_count].to_s(:delimited) rescue nil),
      status_created_at: (@attrs[:status_created_at].to_s(:db) rescue nil),
      labels: labels,
    }
  end
end

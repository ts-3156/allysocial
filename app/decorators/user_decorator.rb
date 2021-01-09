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

  def friends_count
    @attrs[:friends_count]
  end

  def friends_count_s
    friends_count.to_s(:delimited) rescue nil
  end

  def followers_count
    @attrs[:followers_count]
  end

  def followers_count_s
    followers_count.to_s(:delimited) rescue nil
  end

  def one_sided_friends_count
    @options[:user_snapshot]&.one_sided_friends_insight&.users_count
  end

  def one_sided_friends_count_s
    if @options[:user_snapshot]
      one_sided_friends_count.to_s(:delimited) rescue nil
    end
  end

  def one_sided_followers_count
    @options[:user_snapshot]&.one_sided_followers_insight&.users_count
  end

  def one_sided_followers_count_s
    if @options[:user_snapshot]
      one_sided_followers_count.to_s(:delimited) rescue nil
    end
  end

  def mutual_friends_count
    @options[:user_snapshot]&.mutual_friends_insight&.users_count
  end

  def mutual_friends_count_s
    if @options[:user_snapshot]
      mutual_friends_count.to_s(:delimited) rescue nil
    end
  end

  def jobs_count
    if @options[:user_snapshot] && @options[:category]
      @options[:user_snapshot].fetch_insight(@options[:category]).job['words_count'].size
    end
  end

  def jobs_count_s
    if @options[:user_snapshot] && @options[:category]
      jobs_count.to_s(:delimited) rescue nil
    end
  end

  def locations_count
    if @options[:user_snapshot] && @options[:category]
      @options[:user_snapshot].fetch_insight(@options[:category]).location['words_count'].size
    end
  end

  def locations_count_s
    if @options[:user_snapshot] && @options[:category]
      locations_count.to_s(:delimited) rescue nil
    end
  end

  def urls_count
    if @options[:user_snapshot] && @options[:category]
      @options[:user_snapshot].fetch_insight(@options[:category]).url['words_count'].size
    end
  end

  def urls_count_s
    if @options[:user_snapshot] && @options[:category]
      urls_count.to_s(:delimited) rescue nil
    end
  end

  def keywords_count
    if @options[:user_snapshot] && @options[:category]
      @options[:user_snapshot].fetch_insight(@options[:category]).description['words_count'].size
    end
  end

  def keywords_count_s
    if @options[:user_snapshot] && @options[:category]
      keywords_count.to_s(:delimited) rescue nil
    end
  end

  def users_limit
    10000
  end

  def limit_reached?
    friends_count > users_limit / 2 || followers_count > users_limit / 2
  end

  def protected_icon
    if @attrs[:is_protected]
      %Q(<i class="fas fa-lock"></i>)
    end
  end

  def verified_icon
    if @attrs[:is_verified]
      <<-'HTML'
      <span class="fa-stack" style="font-size: 0.5em;">
        <i class="fas fa-certificate fa-stack-2x text-primary"></i>
        <i class="fas fa-check fa-stack-1x fa-inverse"></i>
      </span>
      HTML
    end
  end

  def followers_badge()
    if @options[:category] == 'followers'
      category_badge(I18n.t('templates.search_response_user_template.categories.follower'))
    end
  end

  def one_sided_friends_badge
    if @options[:category] == 'one_sided_friends'
      category_badge(I18n.t('templates.search_response_user_template.categories.one_sided_friend'))
    end
  end

  def one_sided_followers_badge
    if @options[:category] == 'one_sided_followers'
      category_badge(I18n.t('templates.search_response_user_template.categories.one_sided_follower'))
    end
  end

  def mutual_friends_badge
    if @options[:category] == 'mutual_friends'
      category_badge(I18n.t('templates.search_response_user_template.categories.mutual_friend'))
    end
  end

  def category_badge(text)
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

  def active_1hour_badge
    if active_period?(1.hour)
      active_badge(I18n.t('templates.search_response_user_template.active_1hour'))
    end
  end

  def active_12hours_badge
    if active_period?(12.hours)
      active_badge(I18n.t('templates.search_response_user_template.active_12hours'))
    end
  end

  def active_3days_badge
    if active_period?(3.days)
      active_badge(I18n.t('templates.search_response_user_template.active_3days'))
    end
  end

  def active_1week_badge
    if active_period?(1.week)
      active_badge(I18n.t('templates.search_response_user_template.active_1week'))
    end
  end

  def active_badge(text)
    %Q(<span class="badge badge-primary">#{text}</span>)
  end

  def inactive_3months_badge
    if inactive_period?(3.months)
      inactive_badge(I18n.t('templates.search_response_user_template.inactive_3months'))
    end
  end

  def inactive_1month_badge
    if inactive_period?(1.month)
      inactive_badge(I18n.t('templates.search_response_user_template.inactive_1month'))
    end
  end

  def inactive_1week_badge
    if inactive_period?(1.week)
      inactive_badge(I18n.t('templates.search_response_user_template.inactive_1week'))
    end
  end

  def inactive_badge(text)
    %Q(<span class="badge badge-secondary" style="background-color: darkgray;">#{text}</span>)
  end

  def job_label_s
    JobSelector.value_to_label(Occupation.new(@attrs).job_key)
  end

  def job_badges
    Occupation.new(@attrs).job_keys(3).map do |name|
      %Q(<span class="badge badge-success">#{JobSelector.value_to_label(name)}</span>)
    end
  end

  def badges
    [
      mutual_friends_badge || one_sided_followers_badge || one_sided_friends_badge || followers_badge,
      active_1hour_badge || active_12hours_badge || active_3days_badge || active_1week_badge || inactive_3months_badge || inactive_1month_badge || inactive_1week_badge,
      *job_badges,
    ].compact.join('&nbsp;')
  end

  def status_created_at
    ((@attrs[:status_created_at].to_s(:db) + ' UTC') rescue nil)
  end

  def to_hash
    {
      uid: @attrs[:uid].to_s,
      screen_name: @attrs[:screen_name],
      screen_name_s: @attrs[:screen_name]&.truncate(13, omission: '...'),
      name: @attrs[:name],
      name_s: @attrs[:name]&.truncate_2bytes(13, omission: '...'),
      statuses_count: @attrs[:statuses_count],
      statuses_count_s: (@attrs[:statuses_count].to_s(:delimited) rescue nil),
      friends_count: @attrs[:friends_count],
      friends_count_s: (@attrs[:friends_count].to_s(:delimited) rescue nil),
      followers_count: @attrs[:followers_count],
      followers_count_s: (@attrs[:followers_count].to_s(:delimited) rescue nil),
      listed_count: @attrs[:listed_count],
      listed_count_s: (@attrs[:listed_count].to_s(:delimited) rescue nil),
      favourites_count: @attrs[:favourites_count],
      favourites_count_s: (@attrs[:favourites_count].to_s(:delimited) rescue nil),
      one_sided_friends_count: one_sided_friends_count,
      one_sided_friends_count_s: one_sided_friends_count_s,
      one_sided_followers_count: one_sided_followers_count,
      one_sided_followers_count_s: one_sided_followers_count_s,
      mutual_friends_count: mutual_friends_count,
      mutual_friends_count_s: mutual_friends_count_s,
      is_protected: @attrs[:is_protected],
      is_verified: @attrs[:is_verified],
      description: @view_context.strip_tags(@attrs[:description]),
      location: location,
      url: url,
      url_s: url_s,
      profile_image_url: @attrs[:profile_image_url],
      profile_banner_url: @attrs[:profile_banner_url],
      account_created_at: @attrs[:account_created_at],
      status_display: @attrs[:status_id].present?,
      status_id: @attrs[:status_id]&.to_s,
      status_text: @attrs[:status_text],
      status_retweet_count: @attrs[:status_retweet_count],
      status_retweet_count_s: (@attrs[:status_retweet_count].to_s(:delimited) rescue nil),
      status_favorite_count: @attrs[:status_favorite_count],
      status_favorite_count_s: (@attrs[:status_favorite_count].to_s(:delimited) rescue nil),
      status_photos_display: @attrs[:status_photo_urls].present?,
      status_photo_urls: @attrs[:status_photo_urls],
      status_created_at: status_created_at,
      protected_icon: protected_icon,
      verified_icon: verified_icon,
      badges: badges,
    }
  end
end

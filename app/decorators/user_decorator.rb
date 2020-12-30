class UserDecorator
  def initialize(attrs, view_context)
    @attrs = attrs.symbolize_keys
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

  def to_hash
    {
      uid: @attrs[:uid],
      screen_name: @attrs[:screen_name],
      name: @attrs[:name],
      statuses_count: @attrs[:statuses_count],
      statuses_count_s: @attrs[:statuses_count].to_s(:delimited),
      friends_count: @attrs[:friends_count],
      friends_count_s: @attrs[:friends_count].to_s(:delimited),
      followers_count: @attrs[:followers_count],
      followers_count_s: @attrs[:followers_count].to_s(:delimited),
      description: @view_context.strip_tags(@attrs[:description]),
      location: location,
      url: url,
      url_s: url_s,
      profile_image_url: @attrs[:profile_image_url],
      profile_banner_url: @attrs[:profile_banner_url],
      account_created_at: @attrs[:account_created_at],
    }
  end
end

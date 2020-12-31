class ApiUser
  def initialize(attrs)
    @attrs = attrs
  end

  def uid
    @attrs[:id]
  end

  def screen_name
    @attrs[:screen_name]
  end

  def name
    @attrs[:name]
  end

  def statuses_count
    @attrs[:statuses_count]
  end

  def friends_count
    @attrs[:friends_count]
  end

  def followers_count
    @attrs[:followers_count]
  end

  def description
    unless @description
      @description = @attrs[:description]
      if @description
        begin
          @attrs[:entities][:description][:urls].each do |entity|
            @description.gsub!(entity[:url], entity[:expanded_url])
          end
        rescue => e
        end
      end
      @description
    end

    @description
  end

  def location
    @attrs[:location]
  end

  def url
    unless @url
      @url = @attrs[:url]
      if @url
        begin
          @url = @attrs[:entities][:url][:urls][0][:expanded_url]
        rescue => e
        end
      end
    end

    @url
  end

  def profile_image_url
    @attrs[:profile_image_url_https]&.remove('_normal')
  end

  def profile_banner_url
    @attrs[:profile_banner_url] || @attrs[:profile_background_image_url_https]
  end

  def account_created_at
    @attrs[:created_at]
  end

  def status_id
    @attrs.dig(:status, :id)
  end

  def status_text
    unless @status_text
      @status_text = @attrs.dig(:status, :text)
      if @status_text
        begin
          @attrs[:status][:entities][:urls].each do |entity|
            @status_text.gsub!(entity[:url], entity[:expanded_url])
          end
        rescue => e
        end
      end
      @status_text
    end

    @status_text
  end

  def status_created_at
    @attrs.dig(:status, :created_at)
  end

  def to_user_snapshot_attrs
    to_twitter_user_attrs
  end

  def to_twitter_user_attrs
    {
      uid: uid,
      screen_name: screen_name,
      name: name,
      statuses_count: statuses_count,
      friends_count: friends_count,
      followers_count: followers_count,
      description: description,
      location: location,
      url: url,
      profile_image_url: profile_image_url,
      profile_banner_url: profile_banner_url,
      account_created_at: account_created_at,
      status_id: status_id,
      status_text: status_text,
      status_created_at: status_created_at,
    }
  end
end

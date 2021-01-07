class ApiUser
  include HasOccupation

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

  def listed_count
    @attrs[:listed_count]
  end

  def favourites_count
    @attrs[:favourites_count]
  end

  def is_protected
    @attrs[:protected]
  end

  def is_verified
    @attrs[:verified]
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
          Rails.logger.warn "Cannot replace expanded_url screen_name=#{screen_name} exception=#{e.inspect}"
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
          @attrs.dig(:status, :entities, :urls)&.each do |entity|
            @status_text.gsub!(entity[:url], entity[:expanded_url])
          end
        rescue => e
          Rails.logger.warn "Cannot replace expanded_url of status screen_name=#{screen_name} exception=#{e.inspect}"
        end

        begin
          @attrs.dig(:status, :entities, :media)&.each do |entity|
            @status_text.gsub!(entity[:url], entity[:media_url_https])
          end
        rescue => e
          Rails.logger.warn "Cannot replace media_url of status screen_name=#{screen_name} exception=#{e.inspect}"
        end
      end
    end

    @status_text
  end

  def status_retweet_count
    @attrs.dig(:status, :retweeted_status, :retweet_count) || @attrs.dig(:status, :retweet_count)
  end

  def status_favorite_count
    @attrs.dig(:status, :retweeted_status, :favorite_count) || @attrs.dig(:status, :favorite_count)
  end

  def status_photo_urls
    @attrs.dig(:status, :extended_entities, :media)&.select { |s| s[:type] == 'photo' }&.map { |s| s[:media_url_https] }
  rescue => e
    Rails.logger.warn "Cannot extract status_photo_urls screen_name=#{screen_name} exception=#{e.inspect}"
    nil
  end

  def status_created_at
    @attrs.dig(:status, :created_at)
  end

  def to_hash
    to_twitter_user_attrs
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
      listed_count: listed_count,
      favourites_count: favourites_count,
      is_protected: is_protected,
      is_verified: is_verified,
      description: description,
      location: location,
      url: url,
      profile_image_url: profile_image_url,
      profile_banner_url: profile_banner_url,
      account_created_at: account_created_at,
      status_id: status_id,
      status_text: status_text,
      status_retweet_count: status_retweet_count,
      status_favorite_count: status_favorite_count,
      status_photo_urls: status_photo_urls,
      status_created_at: status_created_at,
    }
  end
end

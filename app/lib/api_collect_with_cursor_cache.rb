class ApiCollectWithCursorCache
  def initialize(options)
    @options = options
    @store = ActiveSupport::Cache::RedisCacheStore.new(
      namespace: "#{Rails.env}:AllySocial:ApiCollectWithCursorCache",
      expires_in: 10.minutes,
      redis: self.class.redis
    )
  end

  def read(uid)
    key = cache_key(uid)
    if (data = @store.read(key))
      Rails.logger.debug { "Cache found key=#{key}" }
      JSON.parse(data).symbolize_keys
    else
      Rails.logger.debug { "Cache not found key=#{key}" }
      nil
    end
  end

  def write(uid, data)
    key = cache_key(uid)
    Rails.logger.debug { "Write cache key=#{key}" }
    @store.write(key, data.to_json)
  end

  def fetch(uid, &block)
    if (data = read(uid))
      data
    else
      data = yield
      write(uid, data)
      data
    end
  end

  def cache_key(uid)
    "method:#{@options[:method]}:uid:#{uid}:count:#{@options[:count]}:cursor:#{@options[:cursor]}"
  end

  def self.redis
    @redis ||= Redis.new(db: 3)
  end
end

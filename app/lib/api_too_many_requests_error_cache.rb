class ApiTooManyRequestsErrorCache
  def initialize
    @store = ActiveSupport::Cache::RedisCacheStore.new(
      namespace: "#{Rails.env}:AllySocial:#{self.class}",
      expires_in: 15.minutes,
      redis: self.class.redis
    )
  end

  def error_found?(user_id)
    @store.exist?("user_id:#{user_id}")
  end

  def set_error(user_id)
    @store.write("user_id:#{user_id}", true)
  end

  # For debugging
  def reset_error(user_id)
    @store.delete("user_id:#{user_id}")
  end

  def self.redis
    @redis ||= Redis.new(db: 2)
  end
end

class ApiUsersErrorCache
  def initialize
    @store = ActiveSupport::Cache::RedisCacheStore.new(
      namespace: "#{Rails.env}:AllySocial:ApiUsersErrorCache",
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

  def self.redis
    @redis ||= Redis.new(db: 2)
  end
end

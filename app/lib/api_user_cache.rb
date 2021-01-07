class ApiUserCache
  include HasOccupation

  def initialize
    @store = ActiveSupport::Cache::RedisCacheStore.new(
      namespace: "#{Rails.env}:AllySocial:ApiUserCache",
      expires_in: 10.minutes,
      redis: self.class.redis
    )
  end

  def get_by_uid(uid)
    if (data = @store.read("uid:#{uid}"))
      Entry.from_json(data)
    end
  end

  def get_by_screen_name(screen_name)
    if (data = @store.read("screen_name:#{screen_name}"))
      Entry.from_json(data)
    end
  end

  def set_data(uid, screen_name, error)
    data = Entry.new(uid, screen_name, error).to_json
    @store.write("uid:#{uid}", data) if uid
    @store.write("screen_name:#{screen_name}", data) if screen_name
  end

  def self.redis
    @redis ||= Redis.new(db: 2)
  end

  class Entry
    attr_reader :uid

    def initialize(uid, screen_name, error)
      @uid = uid
      @screen_name = screen_name
      @error = error
    end

    def error?
      @error
    end

    def to_json
      { uid: @uid, screen_name: @screen_name, error: @error }.to_json
    end

    def self.from_json(json)
      data = JSON.parse(json)
      new(data['uid'], data['screen_name'], data['error'])
    end
  end
end

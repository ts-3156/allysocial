class RateLimit
  def initialize(client)
    @status = Twitter::REST::Request.new(client, :get, '/1.1/application/rate_limit_status.json', {}).perform
  end

  def resources
    @status[:resources]
  end

  def context
    @status[:rate_limit_context]
  end

  def verify_credentials
    Resource.new(extract_remaining_and_reset_in(resources[:account][:'/account/verify_credentials']))
  end

  def friend_ids
    Resource.new(extract_remaining_and_reset_in(resources[:friends][:'/friends/ids']))
  end

  def follower_ids
    Resource.new(extract_remaining_and_reset_in(resources[:followers][:'/followers/ids']))
  end

  def users
    Resource.new(extract_remaining_and_reset_in(resources[:users][:'/users/lookup']))
  end

  def search
    Resource.new(extract_remaining_and_reset_in(resources[:search][:'/search/tweets']))
  end

  def to_h
    {
      verify_credentials: verify_credentials,
      friend_ids: friend_ids,
      follower_ids: follower_ids,
      users: users,
      search: search,
    }
  end

  def inspect
    'verify_credentials ' + verify_credentials.inspect +
      ' friend_ids ' + friend_ids.inspect +
      ' follower_ids ' + follower_ids.inspect +
      ' users ' + users.inspect +
      ' search ' + search.inspect
  end

  private

  def extract_remaining_and_reset_in(limit)
    { remaining: limit[:remaining], reset_in: (Time.at(limit[:reset]) - Time.now).round }
  end

  class Resource
    attr_reader :limit, :remaining, :reset

    def initialize(options)
      @remaining = options[:remaining]
      @reset_in = options[:reset_in]
    end
  end
end

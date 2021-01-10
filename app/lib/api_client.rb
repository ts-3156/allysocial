class ApiClient
  def initialize(client)
    @client = client
  end

  # TODO Cache responses

  def user(id)
    RequestWithRetryHandler.new(__method__).perform do
      @client.user(id).attrs
    end
  end

  def users(ids)
    if ids.size > 100
      ids.each_slice(100).map do |ids_array|
        users(ids_array)
      end.flatten
    else
      RequestWithRetryHandler.new(__method__).perform do
        @client.users(ids).map(&:attrs)
      end
    end
  end

  def friend_ids(uid, &block)
    collect_with_cursor_and_cache(__method__, uid, block) do |options|
      @client.send(__method__, uid, options)&.attrs
    end
  end

  def follower_ids(uid, &block)
    collect_with_cursor_and_cache(__method__, uid, block) do |options|
      @client.send(__method__, uid, options)&.attrs
    end
  end

  def collect_with_cursor_and_cache(method_name, uid, callback, &block)
    collect_with_cursor(10) do |options|
      cache = ApiCollectWithCursorCache.new({ method: method_name }.merge(options))

      response = cache.fetch(uid) do
        RequestWithRetryHandler.new(method_name).perform do
          yield(options)
        end
      end

      callback.call(response) if callback

      response
    end
  end

  def collect_with_cursor(loop_limit)
    options = { count: 5000, cursor: -1 }
    collection = []

    loop_limit.times do
      response = yield(options)
      break if response.nil?

      collection << response[:ids]

      break if response[:next_cursor] == 0

      options[:cursor] = response[:next_cursor]
    end

    collection.flatten
  end

  def search(query, count: 100)
    RequestWithRetryHandler.new(__method__).perform do
      @client.search(query, count: count).attrs[:statuses]
    end
  end

  def status(id)
    RequestWithRetryHandler.new(__method__).perform do
      @client.status(id).attrs
    end
  end

  def user_timeline(uid)
    RequestWithRetryHandler.new(__method__).perform do
      @client.user_timeline(uid, count: 200).map(&:attrs)
    end
  end

  def rate_limit
    RateLimit.new(@client)
  end

  class RequestWithRetryHandler
    def initialize(method)
      @method = method
      @retries = 0
    end

    def perform(&block)
      ApplicationRecord.benchmark("Benchmark method=#{@method}", level: :info) do
        yield
      end
    rescue => e
      @retries += 1
      handle_retryable_error(e)
      Rails.logger.info "Retry method=#{@method} exception=#{e.class}"
      retry
    end

    private

    MAX_RETRIES = 3

    def handle_retryable_error(e)
      if TwitterApiStatus.retryable_error?(e)
        if @retries > MAX_RETRIES
          raise
        else
          # Do nothing
        end
      else
        raise e
      end
    end
  end
end

class ApiClient
  def initialize(client)
    @client = client
  end

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

  def friend_ids(uid)
    collect_with_cursor do |options|
      RequestWithRetryHandler.new(__method__).perform do
        @client.friend_ids(uid, options)
      end
    end
  end

  def follower_ids(uid)
    collect_with_cursor do |options|
      RequestWithRetryHandler.new(__method__).perform do
        @client.follower_ids(uid, options)
      end
    end
  end

  def collect_with_cursor
    options = { count: 5000, cursor: -1 }
    collection = []

    # TODO Limit loop count
    while true do
      response = yield(options)
      break if response.nil?

      collection << response.attrs[:ids]

      break if response.attrs[:next_cursor] == 0

      options[:cursor] = response.attrs[:next_cursor]
    end

    collection.flatten
  end

  def search(query, count: 100)
    RequestWithRetryHandler.new(__method__).perform do
      @client.search(query, count: count).attrs[:statuses]
    end
  end

  class RequestWithRetryHandler
    def initialize(method)
      @method = method
      @retries = 0
    end

    def perform(&block)
      ApplicationRecord.benchmark("Benchmark RequestWithRetryHandler#perform method=#{@method}", level: :info) do
        yield
      end
    rescue => e
      @retries += 1
      handle_retryable_error(e)
      Rails.logger.info "RequestWithRetryHandler#perform: retry #{@method}"
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

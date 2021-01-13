require 'net/http'

class EgotterClient
  def friend_ids(uid, options = {})
    collect_with_cursor_and_cache(__method__, uid, options[:loop_limit]) do |opt|
      res = Request.new('/api/v1/friend_ids', uid, opt[:cursor]).perform
      res ? JSON.parse(res).symbolize_keys : nil
    end
  end

  def follower_ids(uid, options = {})
    collect_with_cursor_and_cache(__method__, uid, options[:loop_limit]) do |opt|
      res = Request.new('/api/v1/follower_ids', uid, opt[:cursor]).perform
      res ? JSON.parse(res).symbolize_keys : nil
    end
  end

  def collect_with_cursor_and_cache(method_name, uid, loop_limit, &block)
    collect_with_cursor(loop_limit) do |options|
      cache = ApiCollectWithCursorCache.new({ method: method_name }.merge(options))

      response = cache.fetch(uid) do
        yield(options)
      end

      response
    end
  end

  def collect_with_cursor(loop_limit)
    options = { count: 5000, cursor: -1 }
    collection = []
    loop_limit ||= 5

    loop_limit.times do
      response = yield(options)
      break if response.nil?

      collection << response[:ids]

      break if response[:next_cursor] == 0

      options[:cursor] = response[:next_cursor]
    end

    collection.flatten
  end

  class Request
    def initialize(path, uid, cursor)
      @path = path
      @uid = uid
      @cursor = cursor || -1
      @polling_limit = 10
    end

    def perform
      response = nil
      @polling_limit.times do
        response = post
        case response.code
        when '202'
          Rails.logger.debug response.body
          sleep 1
        when '200'
          return response.body
        else
          raise FetchFailed.new("status=#{response.code} body=#{response.body}")
        end
      end
      raise RetryExhausted.new("status=#{response.code} body=#{response.body}")
    end

    def post
      retries ||= 3
      uri = URI.parse("https://egotter.com#{@path}")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.open_timeout = 3
      https.read_timeout = 3
      req = Net::HTTP::Post.new(uri)
      req.set_form_data(uid: @uid, cursor: @cursor, key: ENV['EGOTTER_KEY'])
      https.start { https.request(req) }
    rescue => e
      if e.message == 'end of file reached' && (retries -= 1) >= 0
        sleep 1
        retry
      else
        raise
      end
    end
  end

  class FetchFailed < StandardError; end

  class RetryExhausted < StandardError; end
end

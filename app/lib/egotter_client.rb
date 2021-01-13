require 'net/http'

class EgotterClient
  def friend_ids(uid, options = {})
    res = Request.new('/api/v1/friend_ids', uid, options[:loop_limit]).perform
    res ? JSON.parse(res)['uids'] : nil
  end

  def follower_ids(uid, options = {})
    res = Request.new('/api/v1/follower_ids', uid, options[:loop_limit]).perform
    res ? JSON.parse(res)['uids'] : nil
  end

  class Request
    def initialize(path, uid, loop_limit)
      @path = path
      @uid = uid
      @loop_limit = loop_limit || 30
      @polling_limit = 20
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
      req.set_form_data(uid: @uid, loop_limit: @loop_limit, key: ENV['EGOTTER_KEY'])
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

require 'net/http'

class EgotterClient
  def friend_ids(uid)
    res = Request.new('/api/v1/friend_ids', uid).perform
    res ? JSON.parse(res)['uids'] : nil
  end

  def follower_ids(uid)
    res = Request.new('/api/v1/follower_ids', uid).perform
    res ? JSON.parse(res)['uids'] : nil
  end

  class Request
    def initialize(path, uid)
      @path = path
      @uid = uid
      @loop_limit = 20
    end

    def perform
      @loop_limit.times do
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
      uri = URI.parse("https://egotter.com#{@path}")
      Net::HTTP.post_form(uri, { uid: @uid, loop_limit: 30, key: ENV['EGOTTER_KEY'] })
    end
  end

  class FetchFailed < StandardError; end

  class RetryExhausted < StandardError; end
end

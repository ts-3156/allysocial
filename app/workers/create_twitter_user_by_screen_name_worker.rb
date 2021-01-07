class CreateTwitterUserByScreenNameWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, screen_name, options = {})
    client = User.find(user_id).api_client
    cache = ApiUserCache.new

    begin
      raw_user = client.user(screen_name)
      api_user = ApiUser.new(raw_user)
      cache.set_data(api_user.uid, api_user.screen_name, false)
      CreateTwitterUsersWorker.perform_async(user_id, [api_user.uid])
      CreateUserSnapshotWorker.perform_async(user_id, api_user.uid)
    rescue => e
      cache.set_data(nil, screen_name, true)
    end
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end
end

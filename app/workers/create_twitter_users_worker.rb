class CreateTwitterUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, uids, options = {})
    user = User.find(user_id)
    client = user.api_client

    api_users = client.users(uids).map { |user| ApiUser.new(user) }
    create_twitter_users(api_users)
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_twitter_users(api_users)
    api_users.uniq!(&:uid)
    insert_time = Time.zone.now
    insert_users = api_users.map(&:to_twitter_user_attrs).each do |user|
      user[:created_at] = user[:updated_at] = insert_time
    end
    insert_users.each_slice(1000) do |users_array|
      TwitterUser.upsert_all(users_array)
    end
  end
end

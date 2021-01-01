class CreateTwitterUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, uids, options = {})
    if uids.size > 100
      uids.uniq.each_slice(100).each do |uids_array|
        CreateTwitterUsersWorker.perform_async(user_id, uids_array, options)
      end
      return
    end

    user = User.find(user_id)
    client = user.api_client
    uids.uniq!

    reject_candidate_uids = TwitterUser.where(uid: uids).where('updated_at > ?', 1.hour.ago).pluck(:uid)
    uids -= reject_candidate_uids

    if uids.empty?
      logger.info 'There are No uids to be updated'
      return
    end

    api_users = client.users(uids).map { |user| ApiUser.new(user) }
    create_twitter_users(api_users)
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_twitter_users(api_users)
    insert_time = Time.zone.now
    insert_users = api_users.map(&:to_twitter_user_attrs).each do |user|
      user[:created_at] = user[:updated_at] = insert_time
    end
    insert_users.each_slice(1000) do |users_array|
      TwitterUser.upsert_all(users_array)
    end
  end
end

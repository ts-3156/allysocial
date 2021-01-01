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

    uids.uniq!

    reject_candidate_uids = TwitterUser.where(uid: uids).where('updated_at > ?', 1.hour.ago).pluck(:uid)
    uids -= reject_candidate_uids if reject_candidate_uids.any?

    if uids.empty?
      logger.info 'There are No uids to be updated'
      return
    end

    client = User.find(user_id).api_client
    api_users = client.users(uids).map { |user| ApiUser.new(user) }
    upsert_records(api_users)
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def upsert_records(api_users)
    insert_time = Time.zone.now
    insert_users = api_users.map(&:to_twitter_user_attrs).each do |user|
      user[:created_at] = user[:updated_at] = insert_time
    end
    TwitterUser.upsert_all(insert_users)
  end
end

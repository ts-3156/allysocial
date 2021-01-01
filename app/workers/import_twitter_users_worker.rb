class ImportTwitterUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(users, options = {})
    if users.size > 100
      users.uniq { |user| user['uid'] }.each_slice(100).each do |users_array|
        ImportTwitterUsersWorker.perform_async(users_array, options)
      end
      return
    end

    users.uniq! { |user| user['uid'] }

    reject_candidate_uids = TwitterUser.where(uid: users.map { |user| user['uid'] }).where('updated_at > ?', 1.hour.ago).pluck(:uid)
    users.reject! { |user| reject_candidate_uids.include?(user['uid']) } if reject_candidate_uids.any?

    if users.empty?
      logger.info 'There are No users to be updated'
      return
    end

    upsert_records(users)
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def upsert_records(users)
    insert_time = Time.zone.now
    users.each do |user|
      user[:created_at] = user[:updated_at] = insert_time
    end
    TwitterUser.upsert_all(users)
  end
end

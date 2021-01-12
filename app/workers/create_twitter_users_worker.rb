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

    if ApiUsersErrorCache.new.error_found?(user_id)
      retry_new_job(user_id, uids, options)
      return
    end

    uids.uniq!
    do_perform(user_id, uids)
  rescue => e
    if TwitterApiStatus.no_user_matches?(e)
      # Do nothing
    elsif TwitterApiStatus.too_many_requests?(e)
      ApiUsersErrorCache.new.set_error(user_id)
      retry_new_job(user_id, uids, options)
    else
      logger.warn "Unhandled exception: #{e.inspect}"
      logger.info e.backtrace.join("\n")
    end
  end

  private

  def do_perform(user_id, uids)
    reject_candidate_uids = TwitterUser.where(uid: uids).where('updated_at > ?', 1.hour.ago).pluck(:uid)
    uids -= reject_candidate_uids if reject_candidate_uids.any?

    if uids.empty?
      logger.info 'There are No uids to be updated'
      return
    end

    client = User.find(user_id).api_client
    api_users = client.users(uids).map { |user| ApiUser.new(user) }
    upsert_records(api_users)
  end

  def upsert_records(api_users)
    retries ||= 3
    insert_time = Time.zone.now
    insert_users = api_users.map(&:to_twitter_user_attrs).each do |user|
      user[:created_at] = user[:updated_at] = insert_time
    end
    TwitterUser.upsert_all(insert_users)
  rescue => e
    if (retries -= 1) >= 0 && e.message.include?('Deadlock found when trying to get lock; try restarting transaction')
      sleep(rand(3) + 1)
      retry
    else
      raise
    end
  end

  def retry_new_job(*args)
    CreateTwitterUsersWorker.perform_in(15.minutes + rand(180), *args)
  end
end

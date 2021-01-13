class CreateFollowersInsightWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, user_snapshot_id, uids, options = {})
    user_snapshot = UserSnapshot.find(user_snapshot_id)
    create_insight(user_id, user_snapshot, uids)
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_insight(user_id, user_snapshot, uids)
    if user_snapshot.followers_insight
      logger.info 'FollowersInsight is already created'
    else
      insight = user_snapshot.create_followers_insight!
      insight.update!(users_count: user_snapshot.followers_count)
      insight.update_from_uids(user_id, uids)
    end
  end
end

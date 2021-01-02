class CreateFriendsInsightWorker
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
    if user_snapshot.friends_insight
      logger.info 'FriendsInsight is already created'
    else
      insight = user_snapshot.create_friends_insight!
      insight.update_from_uids(user_id, uids)
    end
  end
end

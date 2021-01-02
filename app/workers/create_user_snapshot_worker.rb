class CreateUserSnapshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, uid, options = {})
    if (user_snapshot = create_snapshot(user_id, uid))
      CreateFriendsSnapshotWorker.perform_async(user_id, user_snapshot.id)
      CreateFollowersSnapshotWorker.perform_async(user_id, user_snapshot.id)
    end
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_snapshot(user_id, uid)
    if UserSnapshot.where('created_at > ?', 5.minutes.ago).where(uid: uid).exists?
      logger.info 'UserSnapshot is not created'
      nil
    else
      raw_user = User.find(user_id).api_client.user(uid)
      api_user = ApiUser.new(raw_user)
      UserSnapshot.create!(uid: uid, properties: { user: api_user.to_user_snapshot_attrs })
    end
  end
end

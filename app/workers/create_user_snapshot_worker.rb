class CreateUserSnapshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, uid, options = {})
    if (user_snapshot = create_snapshot(user_id, uid, options['force']))
      CreateFriendsSnapshotWorker.perform_async(user_id, user_snapshot.id)
      CreateFollowersSnapshotWorker.perform_async(user_id, user_snapshot.id)
      CreateTwitterUsersWorker.perform_async(user_id, [user_snapshot.uid])
    end
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_snapshot(user_id, uid, force)
    if force ||
      !(user_snapshot = UserSnapshot.where('created_at > ?', 12.hours.ago).latest_by(uid: uid)) ||
      (!user_snapshot.data_completed? && user_snapshot.created_at < 10.minutes.ago)
      create_snapshot!(user_id, uid)
    else
      logger.info 'UserSnapshot is not created'
      nil
    end
  end

  def create_snapshot!(user_id, uid)
    raw_user = User.find(user_id).api_client.user(uid)
    api_user = ApiUser.new(raw_user)
    UserSnapshot.create!(uid: uid, properties: { user: api_user.to_user_snapshot_attrs })
  end
end

class CreateUserSnapshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, options = {})
    user = User.find(user_id)
    client = user.api_client

    if (user_snapshot = create_snapshot(client, user.uid))
      CreateFriendsSnapshotWorker.perform_async(user_id, user_snapshot.id)
      CreateFollowersSnapshotWorker.perform_async(user_id, user_snapshot.id)
    end
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_snapshot(client, uid)
    if UserSnapshot.where('created_at > ?', 5.minutes.ago).where(uid: uid).exists?
      nil
    else
      api_user = client.user(uid)
      UserSnapshot.create!(uid: uid, properties: { user: ApiUser.new(api_user).to_user_snapshot_attrs })
    end
  end
end

class CreateSnapshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, options = {})
    user = User.find(user_id)
    client = user.api_client

    user_snapshot = create_user_snapshot(client, user.uid)
    create_friends_snapshot(client, user_snapshot)
    create_followers_snapshot(client, user_snapshot)
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_user_snapshot(client, uid)
    user_snapshot = UserSnapshot.order(created_at: :desc).where('created_at > ?', 5.minutes.ago).find_by(uid: uid)
    api_user = client.user(uid)

    if !user_snapshot || user_snapshot.api_user_changed?(api_user)
      user_snapshot = UserSnapshot.create!(uid: uid, properties: { user: UserSnapshot.slice_api_user(api_user) })
    end

    user_snapshot
  end

  def create_friends_snapshot(client, user_snapshot)
    unless user_snapshot.friends_snapshot
      ids = client.friend_ids(user_snapshot.uid)
      friends = client.users(ids.take(100)).map { |user| UserSnapshot.slice_api_user(user) }
      user_snapshot.create_friends_snapshot!(properties: { users: friends })
    end
  end

  def create_followers_snapshot(client, user_snapshot)
    unless user_snapshot.followers_snapshot
      ids = client.follower_ids(user_snapshot.uid)
      followers = client.users(ids.take(100)).map { |user| UserSnapshot.slice_api_user(user) }
      user_snapshot.create_followers_snapshot!(properties: { users: followers })
    end
  end
end

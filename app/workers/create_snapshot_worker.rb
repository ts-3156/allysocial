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
      users = client.users(ids.take(5000)).map { |user| UserSnapshot.slice_api_user(user) } # TODO Set suitable limit
      user_snapshot.create_friends_snapshot!(properties: { users: users })

      description_keywords = extract_description_keywords(users)
      location_keywords = extract_location_keywords(users)
      user_snapshot.create_friends_insight!(description_keywords: { words: description_keywords }, location_keywords: { words: location_keywords })
    end
  end

  def create_followers_snapshot(client, user_snapshot)
    unless user_snapshot.followers_snapshot
      ids = client.follower_ids(user_snapshot.uid)
      users = client.users(ids.take(5000)).map { |user| UserSnapshot.slice_api_user(user) } # TODO Set suitable limit
      user_snapshot.create_followers_snapshot!(properties: { users: users })

      description_keywords = extract_description_keywords(users)
      location_keywords = extract_location_keywords(users)
      user_snapshot.create_followers_insight!(description_keywords: { words: description_keywords }, location_keywords: { words: location_keywords })
    end
  end

  def extract_description_keywords(users)
    text = users.take(1000).map { |user| user[:description] }.join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text).keys.take(500)
  end

  def extract_location_keywords(users)
    text = users.take(5000).map { |user| user[:location] }.join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text).keys.take(500)
  end
end

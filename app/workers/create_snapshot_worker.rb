class CreateSnapshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, options = {})
    user = User.find(user_id)
    client = user.api_client

    user_snapshot = create_user_snapshot(client, user.uid)
    friends_api_users = create_friends_snapshot(client, user_snapshot)
    followers_api_users = create_followers_snapshot(client, user_snapshot)
    create_twitter_users(friends_api_users + followers_api_users)
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
    if user_snapshot.friends_snapshot
      []
    else
      ids = client.friend_ids(user_snapshot.uid)
      user_snapshot.create_friends_snapshot!(properties: { uids: ids })

      users = client.users(ids.take(5000)).map { |user| UserSnapshot.slice_api_user(user) } # TODO Set suitable limit
      description_keywords = extract_description_keywords(users)
      location_keywords = extract_location_keywords(users)
      user_snapshot.create_friends_insight!(description_keywords: { words: description_keywords }, location_keywords: { words: location_keywords })

      users
    end
  end

  def create_followers_snapshot(client, user_snapshot)
    if user_snapshot.followers_snapshot
      []
    else
      ids = client.follower_ids(user_snapshot.uid)
      user_snapshot.create_followers_snapshot!(properties: { uids: ids })

      users = client.users(ids.take(5000)).map { |user| UserSnapshot.slice_api_user(user) } # TODO Set suitable limit
      description_keywords = extract_description_keywords(users)
      location_keywords = extract_location_keywords(users)
      user_snapshot.create_followers_insight!(description_keywords: { words: description_keywords }, location_keywords: { words: location_keywords })

      users
    end
  end

  def create_twitter_users(api_users)
    api_users.uniq! { |user| user[:uid] }
    insert_keys = TwitterUser.column_names.map(&:to_sym)
    insert_time = Time.zone.now
    insert_users = api_users.map { |user| user.slice(*insert_keys) }.each { |user| user[:created_at] = insert_time; user[:updated_at] = insert_time }
    insert_users.each_slice(1000) do |users_array|
      TwitterUser.insert_all(users_array)
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

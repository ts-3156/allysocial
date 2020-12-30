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
    if UserSnapshot.where('created_at > ?', 5.minutes.ago).where(uid: uid).exists?
      nil
    else
      api_user = client.user(uid)
      # TODO Save latest status
      UserSnapshot.create!(uid: uid, properties: { user: ApiUser.new(api_user).to_user_snapshot_attrs })
    end
  end

  def create_friends_snapshot(client, user_snapshot)
    if user_snapshot.friends_snapshot
      []
    else
      friends_snapshot = user_snapshot.create_friends_snapshot!

      ids = client.friend_ids(user_snapshot.uid) do |response|
        attrs = response.attrs
        friends_snapshot.friends_responses.create!(previous_cursor: attrs[:previous_cursor], next_cursor: attrs[:next_cursor], properties: { uids: attrs[:ids] })
      end

      # friends_snapshot.update!(properties: { uids: ids })

      users = client.users(ids.take(5000)).map { |user| ApiUser.new(user) } # TODO Set suitable limit
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
      followers_snapshot = user_snapshot.create_followers_snapshot!

      ids = client.follower_ids(user_snapshot.uid) do |response|
        attrs = response.attrs
        followers_snapshot.followers_responses.create!(previous_cursor: attrs[:previous_cursor], next_cursor: attrs[:next_cursor], properties: { uids: attrs[:ids] })
      end

      # user_snapshot.create_followers_snapshot!(properties: { uids: ids })

      users = client.users(ids.take(5000)).map { |user| ApiUser.new(user) } # TODO Set suitable limit
      description_keywords = extract_description_keywords(users)
      location_keywords = extract_location_keywords(users)
      user_snapshot.create_followers_insight!(description_keywords: { words: description_keywords }, location_keywords: { words: location_keywords })

      users
    end
  end

  def create_twitter_users(api_users)
    api_users.uniq!(&:uid)
    insert_time = Time.zone.now
    insert_users = api_users.map(&:to_twitter_user_attrs).each do |user|
      user[:created_at] = user[:updated_at] = insert_time
    end
    insert_users.each_slice(1000) do |users_array|
      TwitterUser.insert_all(users_array)
    end
  end

  def extract_description_keywords(users)
    text = users.take(1000).map(&:description).join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text).keys.take(500)
  end

  def extract_location_keywords(users)
    text = users.take(5000).map(&:location).join(' ') # TODO Set suitable limit
    NattoClient.new.count_words(text).keys.take(500)
  end
end

class CreateFollowersSnapshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, user_snapshot_id, options = {})
    client = User.find(user_id).api_client

    user_snapshot = UserSnapshot.find(user_snapshot_id)
    api_users = create_snapshot(client, user_snapshot)

    ImportTwitterUsersWorker.perform_async(api_users.map(&:to_twitter_user_attrs))
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_snapshot(client, user_snapshot)
    if user_snapshot.followers_snapshot
      []
    else
      followers_snapshot = user_snapshot.create_followers_snapshot!

      ids = client.follower_ids(user_snapshot.uid) do |response|
        attrs = response.attrs
        followers_snapshot.followers_responses.create!(previous_cursor: attrs[:previous_cursor], next_cursor: attrs[:next_cursor], properties: { uids: attrs[:ids] })
      end

      followers_snapshot.update(completed_at: Time.zone.now)

      users = client.users(ids.take(5000)).map { |user| ApiUser.new(user) } # TODO Set suitable limit

      followers_insight = user_snapshot.create_followers_insight!
      followers_insight.update_description_from_users(users)
      followers_insight.update_location_from_users(users)
      followers_insight.update_url_from_users(users)

      followers_insight.update(completed_at: Time.zone.now)

      users
    end
  end
end

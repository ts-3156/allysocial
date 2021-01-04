class CreateFollowersSnapshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, user_snapshot_id, options = {})
    user_snapshot = UserSnapshot.find(user_snapshot_id)
    create_snapshot(user_id, user_snapshot)
  rescue => e
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
  end

  private

  def create_snapshot(user_id, user_snapshot)
    if user_snapshot.followers_snapshot
      logger.info 'FollowersSnapshot is already created'
    else
      snapshot = user_snapshot.create_followers_snapshot!
      snapshot.update_from_user_id(user_id)
    end

    if user_snapshot.friends_snapshot && user_snapshot.followers_snapshot
      unless user_snapshot.one_sided_friends_snapshot
        CreateOneSidedFriendsSnapshotWorker.perform_async(user_id, user_snapshot.id)
      end

      unless user_snapshot.one_sided_followers_snapshot
        CreateOneSidedFollowersSnapshotWorker.perform_async(user_id, user_snapshot.id)
      end

      unless user_snapshot.mutual_friends_snapshot
        CreateMutualFriendsSnapshotWorker.perform_async(user_id, user_snapshot.id)
      end
    end
  end
end

class CreateFriendsSnapshotWorker < CreateSnapshotWorker
  private

  def create_snapshot(user_id, user_snapshot)
    if user_snapshot.friends_snapshot
      logger.info 'FriendsSnapshot is already created'
    else
      snapshot = user_snapshot.create_friends_snapshot!
      snapshot.update_from_user_id(user_id)
      uids = snapshot.users_chunks.first&.uids || []
      CreateFriendsInsightWorker.perform_async(user_id, user_snapshot.id, uids)
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

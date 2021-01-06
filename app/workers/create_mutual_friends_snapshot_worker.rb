class CreateMutualFriendsSnapshotWorker < CreateSnapshotWorker
  private

  def create_snapshot(user_id, user_snapshot)
    if user_snapshot.mutual_friends_snapshot
      logger.info 'MutualFriendsSnapshot is already created'
    else
      snapshot = user_snapshot.create_mutual_friends_snapshot!
      snapshot.update_from_user_snapshot(user_id, user_snapshot)
      CreateMutualFriendsInsightWorker.perform_async(user_id, user_snapshot.id)
    end
  end
end

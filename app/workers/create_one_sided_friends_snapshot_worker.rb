class CreateOneSidedFriendsSnapshotWorker < CreateSnapshotWorker
  private

  def create_snapshot(user_id, user_snapshot)
    if user_snapshot.one_sided_friends_snapshot
      logger.info 'OneSidedFriendsSnapshot is already created'
    else
      snapshot = user_snapshot.create_one_sided_friends_snapshot!
      snapshot.update_from_user_snapshot(user_id, user_snapshot)
      CreateOneSidedFriendsInsightWorker.perform_async(user_id, user_snapshot.id)
    end
  end
end

class CreateOneSidedFollowersSnapshotWorker < CreateSnapshotWorker
  private

  def create_snapshot(user_id, user_snapshot)
    if user_snapshot.one_sided_followers_snapshot
      logger.info 'OneSidedFollowersSnapshot is already created'
    else
      snapshot = user_snapshot.create_one_sided_followers_snapshot!
      snapshot.update_from_user_snapshot(user_id, user_snapshot)
      CreateOneSidedFollowersInsightWorker.perform_async(user_id, user_snapshot.id)
    end
  end
end

class CreateMutualFriendsInsightWorker < CreateInsightWorker
  private

  def create_insight(user_id, user_snapshot)
    if user_snapshot.mutual_friends_insight
      logger.info 'MutualFriendsInsight is already created'
    else
      insight = user_snapshot.create_mutual_friends_insight!
      uids = user_snapshot.mutual_friend_uids(limit: 100000)
      insight.update!(users_count: uids.size)
      insight.update_from_uids(user_id, uids)
    end
  end
end

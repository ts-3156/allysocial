class CreateOneSidedFriendsInsightWorker < CreateInsightWorker
  private

  def create_insight(user_id, user_snapshot)
    if user_snapshot.one_sided_friends_insight
      logger.info 'OneSidedFriendsInsight is already created'
    else
      insight = user_snapshot.create_one_sided_friends_insight!
      uids = user_snapshot.one_sided_friend_uids(limit: 100000)
      insight.update_from_uids(user_id, uids)
    end
  end
end

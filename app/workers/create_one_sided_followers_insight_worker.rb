class CreateOneSidedFollowersInsightWorker < CreateInsightWorker
  private

  def create_insight(user_id, user_snapshot)
    if user_snapshot.one_sided_followers_insight
      logger.info 'OneSidedFollowersInsight is already created'
    else
      insight = user_snapshot.create_one_sided_followers_insight!
      uids = user_snapshot.one_sided_follower_uids(limit: 100000)
      insight.update_from_uids(user_id, uids)
    end
  end
end

module Api
  class FollowersJobSearchesController < BaseController
    before_action :authenticate_user!
    before_action :require_keyword!

    def show
      create_user_snapshot(current_user.uid)
      followers_snapshot = UserSnapshot.order(created_at: :desc).find_by(uid: current_user.uid).followers_snapshot
      users = followers_snapshot.properties['users'].select { |user| user['description']&.include?(params[:q]) }
      render json: { users: users }
    end

    private

    # TODO Call API in background
    def create_user_snapshot(uid)
      client = current_user.api_client

      user_snapshot = UserSnapshot.order(created_at: :desc).where('created_at > ?', 5.minutes.ago).find_by(uid: uid)
      api_user = client.user(uid)

      if !user_snapshot || user_snapshot.api_user_changed?(api_user)
        user_snapshot = UserSnapshot.create!(uid: uid, properties: { user: UserSnapshot.slice_api_user(api_user) })
      end

      unless user_snapshot.friends_snapshot
        ids = client.friend_ids(user_snapshot.uid)
        friends = client.users(ids.take(100)).map { |user| UserSnapshot.slice_api_user(user) }
        user_snapshot.create_friends_snapshot!(properties: { users: friends })
      end

      unless user_snapshot.followers_snapshot
        ids = client.follower_ids(user_snapshot.uid)
        followers = client.users(ids.take(100)).map { |user| UserSnapshot.slice_api_user(user) }
        user_snapshot.create_followers_snapshot!(properties: { users: followers })
      end
    end

    def require_keyword!
      raise ':q not specified' unless params[:q] && params[:q].match?(/\A.{,50}\z/)
    end
  end
end

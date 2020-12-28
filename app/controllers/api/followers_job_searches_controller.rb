module Api
  class FollowersJobSearchesController < BaseController
    before_action :authenticate_user!
    before_action :require_keyword!
    before_action :set_user_snapshot

    def show
      users = @user_snapshot.followers_snapshot.users.select { |user| user.match_job?(params[:q]) }
      render json: { users: users.map(&:to_hash) }
    end

    private

    def require_keyword!
      raise ':q not specified' unless params[:q] && params[:q].match?(/\A.{,50}\z/)
    end

    def set_user_snapshot
      @user_snapshot = UserSnapshot.order(created_at: :desc).find_by(uid: current_user.uid)
      unless @user_snapshot
        CreateSnapshotWorker.perform_async(current_user.id)
        render json: { message: 'Not found' }, status: :not_found
      end
    end
  end
end

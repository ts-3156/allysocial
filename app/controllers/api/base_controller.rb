module Api
  class BaseController < ApplicationController
    rescue_from StandardError do |e|
      logger.warn "Unhandled exception: #{e.inspect}"
      logger.info e.backtrace.join("\n")
      render json: { message: 'error' }, status: :internal_server_error
    end

    private

    def require_category
      unless params[:category] && params[:category].match?(/\A(friends|followers|one_sided_friends|one_sided_followers|mutual_friends)\z/)
        render json: { message: ':category not specified' }, status: :bad_request
      end
    end

    def require_type
      unless params[:type] && params[:type].match?(/\A(job|location|url|keyword)\z/)
        render json: { message: ':type not specified' }, status: :bad_request
      end
    end

    def require_uid
      if current_user.has_subscription?
        raise ':uid not specified' if !params[:uid] || !params[:uid].match?(/\A[1-9][0-9]{1,30}\z/)
      else
        raise ':uid not specified' if current_user.uid != params[:uid]
      end
    end

    def set_user_snapshot(uid)
      if current_user.has_subscription?
        snapshot = UserSnapshot.latest_by(uid: uid)
      else
        snapshot = current_user.user_snapshot
      end

      if snapshot&.data_completed?
        @user_snapshot = snapshot
      else
        create_user_snapshot(uid)
        render json: { message: 'Not found' }, status: :not_found
      end
    end

    def create_user_snapshot(uid)
      if current_user.has_subscription?
        user = TwitterUser.find_by(uid: uid)
        user = fetch_raw_user(uid) unless user
        CreateUserSnapshotWorker.perform_async(current_user.id, user.uid) if user
      else
        CreateUserSnapshotWorker.perform_async(current_user.id, current_user.uid)
      end
    end

    def fetch_raw_user(uid)
      # TODO Error handling
      user = current_user.api_client.user(uid)
      ApiUser.new(user)
    rescue => e
      logger.warn e.inspect
      nil
    end

    def set_insight
      case params[:category]
      when 'friends'
        @insight = @user_snapshot.friends_insight
      when 'followers'
        @insight = @user_snapshot.followers_insight
      when 'one_sided_friends'
        @insight = @user_snapshot.one_sided_friends_insight
      when 'one_sided_followers'
        @insight = @user_snapshot.one_sided_followers_insight
      when 'mutual_friends'
        @insight = @user_snapshot.mutual_friends_insight
      else
        render json: { message: ':category not specified' }, status: :bad_request
      end
    end

    def strip_tags(value)
      @view_context ||= view_context
      @view_context.strip_tags(value)
    end
  end
end

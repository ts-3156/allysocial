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

    def set_user_snapshot
      if !(@user_snapshot = current_user.user_snapshot) || !@user_snapshot.data_completed?
        CreateUserSnapshotWorker.perform_async(current_user.id, current_user.uid)
        render json: { message: 'Not found' }, status: :not_found
      end
    end

    def set_insight
      case params[:category]
      when 'friends'
        @insight = @user_snapshot.friends_insight
      when 'followers'
        @insight = @user_snapshot.followers_insight
      when 'one_sided_friends'
        @insight = @user_snapshot.friends_insight
      when 'one_sided_followers'
        @insight = @user_snapshot.followers_insight
      when 'mutual_friends'
        @insight = @user_snapshot.friends_insight
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

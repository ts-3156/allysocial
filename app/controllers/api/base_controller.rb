module Api
  class BaseController < ApplicationController

    before_action :require_referer

    rescue_from StandardError do |e|
      logger.warn "Unhandled exception: #{e.inspect}"
      logger.info e.backtrace.join("\n")
      render json: { message: 'error' }, status: :internal_server_error
    end

    private

    def require_referer
      if request.referer.blank?
        render json: { message: ':referer not specified' }, status: :bad_request
      end
    end

    def category_regexp
      if current_user.has_subscription?(:plus)
        /\A(friends|followers|one_sided_friends|one_sided_followers|mutual_friends)\z/
      else
        /\A(friends|followers)\z/
      end
    end

    def require_category
      unless params[:category] && params[:category].match?(category_regexp)
        render json: { message: ':category not specified' }, status: :bad_request
      end
    end

    def require_type
      unless params[:type] && params[:type].match?(/\A(job|location|url|keyword)\z/)
        render json: { message: ':type not specified' }, status: :bad_request
      end
    end

    def require_uid
      if current_user.has_subscription?(:pro)
        raise ':uid not specified' if !params[:uid] || !params[:uid].match?(/\A[1-9][0-9]{1,30}\z/)
      else
        raise ':uid not specified' if current_user.uid != params[:uid].to_i
      end
    end

    # TODO Check permission
    def set_user_snapshot(uid, wait_for_completion = true)
      if current_user.has_subscription?(:pro)
        snapshot = UserSnapshot.latest_by(uid: uid)
      else
        snapshot = current_user.user_snapshot
      end

      if (wait_for_completion && snapshot&.data_completed?) || (!wait_for_completion && snapshot)
        @user_snapshot = snapshot
      else
        unless ApiTooManyRequestsErrorCache.new.error_found?(current_user.id)
          create_user_snapshot(uid)
        end

        screen_name = (user = TwitterUser.find_by(uid: uid)) ? user.screen_name : 'user'
        message = t('api.base.data_not_completed_html', app: t('app_name'), user: screen_name, url: view_context.image_path('/ajax-loader.gif'))
        render json: { message: message }, status: :accepted
      end
    end

    def create_user_snapshot(uid)
      if current_user.has_subscription?(:pro)
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

    def has_subscription
      unless current_user.has_subscription?(:plus)
        render json: { message: "You don't have any subscription" }, status: :bad_request
      end
    end

    def has_no_subscription
      if current_user.has_subscription?(:plus)
        render json: { message: 'You already have a subscription' }, status: :bad_request
      end
    end

    def strip_tags(value)
      @view_context ||= view_context
      @view_context.strip_tags(value)
    end
  end
end

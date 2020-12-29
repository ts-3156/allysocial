module Api
  class BaseController < ApplicationController
    rescue_from StandardError do |e|
      logger.warn "Unhandled exception: #{e.inspect}"
      logger.info e.backtrace.join("\n")
      render json: { message: 'error' }, status: :internal_server_error
    end

    private

    def user_to_hash(user)
      user.symbolize_keys!
      user[:location] = 'none' if user[:location].blank? || user[:location].match?(/\A\s+\z/)
      if user[:url].blank? || user[:url].match?(/\A\s+\z/)
        user[:url] = '#'
        user[:url_s] = 'none'
      else
        user[:url_s] = user[:url].remove(/(\Ahttps?:\/\/)|(\/\z)/).truncate(30) if user[:url].match?(/(\Ahttps?:\/\/)|(\/\z)/)
      end
      user[:statuses_count_s] = user[:statuses_count].to_s(:delimited)
      user[:friends_count_s] = user[:friends_count].to_s(:delimited)
      user[:followers_count_s] = user[:followers_count].to_s(:delimited)
      user[:description] = strip_tags(user[:description])
      user
    end

    def set_user_snapshot
      unless (@user_snapshot = current_user.user_snapshot)
        CreateSnapshotWorker.perform_async(current_user.id)
        render json: { message: 'Not found' }, status: :not_found
      end
    end

    def strip_tags(value)
      @view_context ||= view_context
      @view_context.strip_tags(value)
    end
  end
end

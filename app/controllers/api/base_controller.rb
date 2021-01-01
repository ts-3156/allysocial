module Api
  class BaseController < ApplicationController
    rescue_from StandardError do |e|
      logger.warn "Unhandled exception: #{e.inspect}"
      logger.info e.backtrace.join("\n")
      render json: { message: 'error' }, status: :internal_server_error
    end

    private

    def set_user_snapshot
      if !(@user_snapshot = current_user.user_snapshot) || !@user_snapshot.data_completed?
        CreateUserSnapshotWorker.perform_async(current_user.id)
        render json: { message: 'Not found' }, status: :not_found
      end
    end

    def strip_tags(value)
      @view_context ||= view_context
      @view_context.strip_tags(value)
    end
  end
end

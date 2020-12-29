class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  rescue_from StandardError do |e|
    logger.warn "Unhandled exception: #{e.inspect}"
    logger.info e.backtrace.join("\n")
    flash[:alert] = t('.failure', reason: 'Error')
    redirect_to root_path(via: 'auth_exception')
  end

  def twitter
    user = User.from_omniauth(request.env['omniauth.auth']) do |context, user|
      if context == :create
        CreateSnapshotWorker.perform_async(user.id)
      end
    end
    sign_in user, event: :authentication
    flash[:notice] = t('.success')
    redirect_to dashboard_path(via: 'auth_success')
  end

  def failure
    flash[:alert] = t('.failure', reason: request.env['omniauth.error.type'])
    redirect_to root_path(via: 'auth_failure')
  end
end

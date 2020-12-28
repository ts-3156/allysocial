class TwitterApiStatus

  class << self
    def connection_reset_by_peer?(ex)
      ex && ex.message.include?('Connection reset by peer')
    end

    def internal_server_error?(ex)
      ex && ex.class == Twitter::Error::InternalServerError && ['Internal error', ''].include?(ex.message)
    end

    def service_unavailable?(ex)
      ex && ex.class == Twitter::Error::ServiceUnavailable && ['Over capacity', ''].include?(ex.message)
    end

    def execution_expired?(ex)
      ex && ex.class == Twitter::Error && ex.message == 'execution expired'
    end

    def http_timeout?(ex)
      ex && ex.class.to_s.downcase.include?('timeout')
    end

    def retryable_error?(ex)
      connection_reset_by_peer?(ex) ||
        internal_server_error?(ex) ||
        service_unavailable?(ex) ||
        execution_expired?(ex) ||
        http_timeout?(ex)
    end

    def not_found?(ex)
      ex && ex.class == Twitter::Error::NotFound && ex.message == 'User not found.'
    end

    def no_user_matches?(ex)
      ex && ex.class == Twitter::Error::NotFound && ex.message == 'No user matches for specified terms.'
    end

    def forbidden?(ex)
      ex && ex.class == Twitter::Error::Forbidden
    end

    def suspended?(ex)
      ex && ex.class == Twitter::Error::Forbidden && ex.message == 'User has been suspended.'
    end

    # This exception is raised when calling #user_timeline
    def blocked?(ex)
      ex && ex.class == Twitter::Error::Unauthorized && ex.message == "You have been blocked from viewing this user's profile."
    end

    # This exception is raised when calling #user_timeline
    # TODO Rename to not_authorized?
    def protected?(ex)
      ex && ex.class == Twitter::Error::Unauthorized && ex.message == "Not authorized."
    end

    def unauthorized?(ex)
      invalid_or_expired_token?(ex) || bad_authentication_data?(ex)
    end

    def invalid_or_expired_token?(ex)
      ex && ex.class == Twitter::Error::Unauthorized && ex.message == 'Invalid or expired token.'
    end

    def could_not_authenticate_you?(ex)
      ex && ex.class == Twitter::Error::Unauthorized && ex.message == 'Could not authenticate you.'
    end

    def bad_authentication_data?(ex)
      ex && ex.class == Twitter::Error::BadRequest && ex.message == 'Bad Authentication data.'
    end

    def too_many_requests?(ex)
      # Sometimes the 'Rate limit exceeded' message is not set
      ex && ex.class == Twitter::Error::TooManyRequests
    end

    def temporarily_locked?(ex)
      ex && ex.class == Twitter::Error::Forbidden && ex.message == 'To protect our users from spam and other malicious activity, this account is temporarily locked. Please log in to https://twitter.com to unlock your account.'
    end

    def your_account_suspended?(ex)
      ex.class == Twitter::Error::Forbidden && ex.message == "Your account is suspended and is not permitted to access this feature."
    end

    # This exception is raised when calling #follow!
    def blocked_from_following?(ex)
      ex && ex.class == Twitter::Error::Forbidden && ex.message == 'You have been blocked from following this account at the request of the user.'
    end

    # This exception is raised when calling #follow!
    def unable_to_follow?(ex)
      ex && ex.class == Twitter::Error::Forbidden && ex.message == "You are unable to follow more people at this time. Learn more <a href='http://support.twitter.com/articles/66885-i-can-t-follow-people-follow-limits'>here</a>."
    end
  end
end

class ThanksController < ApplicationController
  before_action :authenticate_user

  def index
    if params[:via] == 'checkout_success'
      if current_user.has_subscription?(:plus)
        subscription = current_user.current_subscription
        @message = t('.success', name: subscription.name)
      else
        @message = t('.failure')
      end
    else
      @message = t('.signed_in')
    end
  end
end

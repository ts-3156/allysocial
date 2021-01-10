module Api
  class SubscriptionsController < BaseController
    before_action :authenticate_user!

    def destroy
      subscription = current_user.subscriptions.find_by(id: params[:id])
      subscription.cancel! unless subscription.canceled?
      render json: { message: t('.destroy') }
    end
  end
end

module Api
  class CheckoutSessionsController < BaseController

    before_action :authenticate_user
    before_action :has_no_subscription

    def create
      locale = I18n.locale
      attrs = {
        client_reference_id: current_user.id,
        payment_method_types: ['card'],
        mode: 'subscription',
        line_items: [{ quantity: 1, price: Subscription::PRICE_IDS[locale] }],
        subscription_data: { default_tax_rates: [Subscription::TAX_ID] },
        metadata: { user_id: current_user.id },
        success_url: dashboard_url(via: 'checkout_success'),
        cancel_url: root_url(via: 'checkout_cancel')
      }

      if (subscription = current_user.subscriptions.order(created_at: :desc).first)
        attrs[:customer] = subscription.stripe_customer_id
      else
        attrs[:discounts] = [{ coupon: Subscription::COUPON_IDS[locale] }]
      end

      render json: { session_id: Stripe::Checkout::Session.create(attrs).id }
    end
  end
end

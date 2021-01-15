module Api
  class WebhooksController < BaseController

    skip_before_action :verify_authenticity_token
    skip_before_action :require_referer

    rescue_from StandardError do |e|
      logger.warn "Unhandled exception: #{e.inspect}"
      logger.info e.backtrace.join("\n")
      head :bad_request
    end

    def create
      event = construct_webhook_event
      process_webhook_event(event)
      head :ok
    end

    private

    def construct_webhook_event
      payload = request.body.read
      sig_header = request.headers['HTTP_STRIPE_SIGNATURE']
      Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_ENDPOINT_SECRET'])
    end

    def process_webhook_event(event)
      case event.type
      when 'checkout.session.completed'
        checkout_session_completed(event.data.object)
      else
        logger.info "Unhandled stripe webhook event type=#{event.type} value=#{event.inspect}"
      end
    end

    def checkout_session_completed(checkout_session)
      user_id = checkout_session.client_reference_id
      user = User.find(user_id)
      subscription_id = checkout_session.subscription

      if user.has_subscription?(:plus)
        Stripe::Subscription.delete(subscription_id)
        logger.warn "#{Rails.env}:checkout_session_completed already purchased user_id=#{user.id}"
      else
        Stripe::Customer.update(checkout_session.customer, { metadata: { user_id: user_id } })
        customer = Stripe::Customer.retrieve(checkout_session.customer)

        subscription = Subscription.create_by(checkout_session, customer)
        Stripe::Subscription.update(subscription_id, { metadata: { user_id: user_id, sub_id: subscription.id } })

        logger.info "#{Rails.env}:checkout_session_completed success user_id=#{user.id} subscription_id=#{subscription.id}"
      end
    end
  end
end

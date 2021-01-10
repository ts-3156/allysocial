# == Schema Information
#
# Table name: subscriptions
#
#  id                         :bigint           not null, primary key
#  user_id                    :bigint           not null
#  email                      :string(255)
#  name                       :string(255)
#  price                      :integer
#  tax_rate                   :decimal(4, 2)
#  stripe_checkout_session_id :string(255)
#  stripe_customer_id         :string(255)
#  stripe_subscription_id     :string(255)
#  trial_end_at               :datetime
#  canceled_at                :datetime
#  charge_failed_at           :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
class Subscription < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :email, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :tax_rate, presence: true
  validates :stripe_checkout_session_id, presence: true, uniqueness: true
  validates :stripe_customer_id, presence: true, uniqueness: true
  validates :stripe_subscription_id, presence: true, uniqueness: true

  scope :not_canceled, -> { where(canceled_at: nil) }
  scope :charge_not_failed, -> { where(charge_failed_at: nil) }

  PRODUCT_ID = ENV['STRIPE_PRODUCT_ID']
  PRICE_ID = ENV['STRIPE_PRICE_ID']
  TAX_ID = ENV['STRIPE_TAX_ID']
  COUPON_ID = ENV['STRIPE_COUPON_ID']
  PRODUCT_NAME = "#{I18n.t('app_name')} Pro"
  TAX_RATE = 0.1
  PRICE = 2980

  def canceled?
    canceled_at.present?
  end

  def cancel!
    Stripe::Subscription.delete(subscription_id)
    update!(canceled_at: Time.zone.now)
  end

  class << self
    def create_by(checkout_session, customer)
      create!(
        user_id: checkout_session.client_reference_id,
        email: customer.email,
        name: PRODUCT_NAME,
        price: PRICE,
        tax_rate: TAX_RATE,
        stripe_checkout_session_id: checkout_session.id,
        stripe_customer_id: checkout_session.customer,
        stripe_subscription_id: checkout_session.subscription,
      )
    end
  end
end

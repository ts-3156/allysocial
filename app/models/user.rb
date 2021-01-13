# == Schema Information
#
# Table name: users
#
#  id          :bigint           not null, primary key
#  uid         :bigint           not null
#  screen_name :string(255)      not null
#  email       :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :omniauthable, omniauth_providers: %i(twitter)

  has_one :credential
  has_many :subscriptions

  validates :uid, presence: true, uniqueness: true
  validates :email, presence: true

  def api_client
    ApiClient.new(
      Twitter::REST::Client.new(
        consumer_key: ENV['TWITTER_API_KEY'],
        consumer_secret: ENV['TWITTER_API_SECRET_KEY'],
        access_token: credential.access_token,
        access_token_secret: credential.access_secret,
        timeouts: { connect: 1, read: 2, write: 4 }
      )
    )
  end

  def user_snapshot
    UserSnapshot.latest_by(uid: uid)
  end

  def to_user_decorator(view_context)
    user_snapshot.to_user_decorator({}, view_context)
  end

  SUBSCRIPTION_TYPES = %i(plus pro)

  def has_subscription?(type = SUBSCRIPTION_TYPES[0])
    # TODO Use type
    subscriptions.not_canceled.charge_not_failed.any?
  end

  def current_subscription
    subscriptions.not_canceled.charge_not_failed.order(created_at: :desc).first
  end

  def profile_image_url
    user_snapshot&.properties&.dig('profile_image_url')
  end

  class << self
    def from_omniauth(auth)
      user = find_or_initialize_by(uid: auth.uid)
      user.assign_attributes(screen_name: auth.info.nickname, email: auth.info.email)

      if user.new_record?
        transaction do
          user.save!
          user.create_credential!(authorized: true, access_token: auth.credentials.token, access_secret: auth.credentials.secret)
        end

        yield(:create, user)
      else
        user.save! if user.changed?

        user.credential.assign_attributes(access_token: auth.credentials.token) if auth.credentials.token.present?
        user.credential.assign_attributes(access_secret: auth.credentials.secret) if auth.credentials.secret.present?
        if user.credential.changed?
          user.credential.authorized = true
          user.credential.save!
        end

        yield(:update, user)
      end

      user
    rescue => e
      logger.warn "from_omniauth: cannot save user and credential exception=#{e.inspect} auth=#{auth.inspect}"
      raise
    end
  end

end

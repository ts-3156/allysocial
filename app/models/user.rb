class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :omniauthable, omniauth_providers: %i(twitter)

  has_one :credential

  validates :uid, presence: true, uniqueness: true
  validates :email, presence: true

  class << self
    def from_omniauth(auth)
      user = find_or_initialize_by(uid: auth.uid)
      user.assign_attributes(screen_name: auth.info.nickname, email: auth.info.email)

      if user.new_record?
        transaction do
          user.save!
          user.create_credential!(authorized: true, access_token: auth.credentials.token, access_secret: auth.credentials.secret)
        end
      else
        user.save! if user.changed?

        user.credential.assign_attributes(access_token: auth.credentials.token) if auth.credentials.token.present?
        user.credential.assign_attributes(access_secret: auth.credentials.secret) if auth.credentials.secret.present?
        if user.credential.changed?
          user.credential.authorized = true
          user.credential.save!
        end
      end

      user
    rescue => e
      logger.warn "from_omniauth: cannot save user and credential exception=#{e.inspect} auth=#{auth.inspect}"
      raise
    end
  end

end

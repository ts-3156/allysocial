# == Schema Information
#
# Table name: twitter_users
#
#  id                    :bigint           not null, primary key
#  uid                   :bigint           not null
#  screen_name           :string(255)      not null
#  name                  :string(255)      not null
#  statuses_count        :integer          not null
#  friends_count         :integer          not null
#  followers_count       :integer          not null
#  listed_count          :integer
#  favourites_count      :integer
#  is_protected          :boolean
#  is_verified           :boolean
#  description           :text(65535)
#  location              :string(255)
#  url                   :text(65535)
#  profile_image_url     :string(255)
#  profile_banner_url    :string(255)
#  account_created_at    :datetime
#  status_id             :bigint
#  status_text           :text(65535)
#  status_retweet_count  :integer
#  status_favorite_count :integer
#  status_photo_urls     :json
#  status_created_at     :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class TwitterUser < ApplicationRecord
  include HasOccupation

  Occupation.job_detector_methods.each do |method_name|
    define_method("#{method_name}?") do |*args, &blk|
      occupation.send("#{method_name}?")
    end
  end

  def to_user_decorator(options, view_context)
    UserDecorator.new(attributes, options, view_context)
  end

  class << self
    def search_location(str)
      where('location like ?', "%#{sanitize_sql_like(str)}%")
    end

    def japan
      Location.japan(self)
    end

    def kanto
      Location.kanto(self)
    end

    def tokyo
      Location.tokyo(self)
    end

    def search_url(str)
      where('url like ?', "%#{sanitize_sql_like(str)}%")
    end

    def instagram
      where('url regexp "[Ii]nstagram"')
    end

    def tiktok
      where('url regexp "[Tt]ik[Tt]ok"')
    end

    def youtube
      where('url regexp "[Yy]ou[Tt]ube"')
    end

    def search_keyword(str)
      where('description like ?', "%#{sanitize_sql_like(str)}%")
    end

    def accepting_requests_for_work
      freelancer
    end

    Occupation.job_detector_methods.each do |method_name|
      define_method(method_name) do |*args, &blk|
        Occupation.send(method_name, TwitterUser)
      end
    end

    def not_applicable
      base = self
      query = nil
      Occupation.job_detector_methods.each do |method_name|
        query = query ? query.or(base.send(method_name)) : base.send(method_name)
      end
      where.not(query.arel.where_sql.delete_prefix('WHERE '))
    rescue => e
      none
    end

    def order_by_field(uids)
      order(Arel.sql("field(uid, #{uids.join(',')})"))
    end
  end
end

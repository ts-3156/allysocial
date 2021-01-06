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
#  url                   :string(255)
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
  class << self
    def search_location(str)
      where('location like ?', "%#{sanitize_sql_like(str)}%")
    end

    def japan
      where('location regexp "[Jj]apan|[Nn]ihon|[Nn]ippon|日本|にほん"')
    end

    def kanto
      where('location regexp "[Kk]anto|関東|かんとう|[Tt]okyo|東京都?|とうきょう|[Ii]baraki|茨城県?|いばらき|[Tt]o(chi|ti)gi|栃木県?|とちぎ|[Gg]unma|群馬県?|ぐんま|[Ss]aitama|埼玉県?|さいたま|([Cc]hi|[Tt]i)ba|千葉県?|ちば|[Kk]anagawa|神奈川県?|かながわ"')
    end

    def tokyo
      tokyo_23ku.or(tokyo_yamanote)
    end

    def tokyo_23ku
      where('location regexp "[Tt]okyo|東京都?|とうきょう|千代田区?|ちよだく?|中央区|ちゅうおうく|港区|みなとく|新宿区?|しんじゅくく?|文京区?|ぶんきょうく?|台東区?|たいとうく?|墨田区?|すみだく?|江東区?|こうとうく?|品川区?|しながわく?|目黒区?|めぐろく?|大田区?|おおたく?|世田谷区?|せたがやく?|渋谷区?|しぶやく?|中野区?|なかのく?|杉並区?|すぎなみく?|豊島区?|とよしまく?|北区|きたく|荒川区?|あらかわく?|板橋区?|いたばしく?|練馬区?|ねりまく?|足立区?|あだちく?|葛飾区?|かつしかく?|江戸川区?|えどがわく?"')
    end

    def tokyo_yamanote
      where('location regexp "池袋|上野|秋葉原|神田|有楽町|品川|大崎|五反田|目黒|恵比寿|渋谷|原宿|代々木|新宿|新大久保|高田馬場"')
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

    def youtuber
      Occupation.youtuber(self)
    end

    def engineer
      Occupation.engineer(self)
    end

    def freelancer
      Occupation.freelancer(self)
    end

    def influencer
      Occupation.influencer(self)
    end

    def lawyer
      Occupation.lawyer(self)
    end

    def public_accountant
      Occupation.public_accountant(self)
    end

    def tax_accountant
      Occupation.tax_accountant(self)
    end

    def entrepreneur
      Occupation.entrepreneur(self)
    end

    def investor
      Occupation.investor(self)
    end

    def politician
      Occupation.politician(self)
    end

    def political_activist
      Occupation.political_activist(self)
    end

    def designer
       Occupation.designer(self)
    end

    def illustrator
       Occupation.illustrator(self)
    end

    def painter
       Occupation.painter(self)
    end

    def sculptor
       Occupation.sculptor(self)
    end

    def photographer
       Occupation.photographer(self)
    end

    def manga_artist
       Occupation.manga_artist(self)
    end

    def writer
       Occupation.writer(self)
    end

    def culinary_researcher
       Occupation.culinary_researcher(self)
    end

    def comedian
       Occupation.comedian(self)
    end

    def bikini_model
       Occupation.bikini_model(self)
    end

    def fashion_model
       Occupation.fashion_model(self)
    end

    def pop_idol
       Occupation.pop_idol(self)
    end

    def concafe_waitress
       Occupation.concafe_waitress(self)
    end

    def girls_bar_waitress
       Occupation.girls_bar_waitress(self)
    end

    def migrant_worker
       Occupation.migrant_worker(self)
    end

    def nightlife_business
       Occupation.nightlife_business(self)
    end

    def part_timer
       Occupation.part_timer(self)
    end

    def general_student
       Occupation.general_student(self)
    end

    def high_school_student
       Occupation.high_school_student(self)
    end

    def art_student
      Occupation.art_student(self)
    end

    def college_student
      Occupation.college_student(self)
    end

    def order_by_field(uids)
      order(Arel.sql("field(uid, #{uids.join(',')})"))
    end
  end
end

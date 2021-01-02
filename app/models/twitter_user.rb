# == Schema Information
#
# Table name: twitter_users
#
#  id                 :bigint           not null, primary key
#  uid                :bigint           not null
#  screen_name        :string(255)      not null
#  name               :string(255)      not null
#  statuses_count     :integer          not null
#  friends_count      :integer          not null
#  followers_count    :integer          not null
#  description        :text(65535)
#  location           :string(255)
#  url                :string(255)
#  profile_image_url  :string(255)
#  profile_banner_url :string(255)
#  account_created_at :datetime
#  status_id          :bigint
#  status_text        :text(65535)
#  status_created_at  :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
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
      where('location regexp "[Kk]anto|関東|かんとう|[Tt]okyo|東京|とうきょう|[Ii]baraki|茨城|いばらき|[Tt]o(chi|ti)gi|栃木|とちぎ|[Gg]unma|群馬|ぐんま|[Ss]aitama|埼玉|さいたま|([Cc]hi|[Tt]i)ba|千葉|ちば|[Kk]anagawa|神奈川|かながわ"')
    end

    def tokyo
      tokyo_23ku.or(tokyo_yamanote)
    end

    def tokyo_23ku
      where('location regexp "[Tt]okyo|東京|とうきょう|千代田区?|ちよだく?|中央区|ちゅうおうく|港区|みなとく|新宿区?|しんじゅくく?|文京区?|ぶんきょうく?|台東区?|たいとうく?|墨田区?|すみだく?|江東区?|こうとうく?|品川区?|しながわく?|目黒区?|めぐろく?|大田区?|おおたく?|世田谷区?|せたがやく?|渋谷区?|しぶやく?|中野区?|なかのく?|杉並区?|すぎなみく?|豊島区?|とよしまく?|北区|きたく|荒川区?|あらかわく?|板橋区?|いたばしく?|練馬区?|ねりまく?|足立区?|あだちく?|葛飾区?|かつしかく?|江戸川区?|えどがわく?"')
    end

    def tokyo_yamanote
      where('location regexp "池袋|上野|秋葉原|神田|有楽町|品川|大崎|五反田|目黒|恵比寿|渋谷|原宿|代々木|新宿|新大久保|高田馬場"')
    end

    def search_url(str)
      where('url like ?', "%#{sanitize_sql_like(str)}%")
    end

    def search_description(str)
      where('description like ?', "%#{sanitize_sql_like(str)}%")
    end

    def engineer
      where('description regexp "([Ee])ngineer|エンジニア|開発者|Python|Ruby|Golang|Java|Scala"')
    end

    def freelancer
      requests_for_work = '([Ff])reelance|フリーランス|(仕事.*依頼)|(依頼.+DM)'
      where(%Q(description regexp "#{requests_for_work}" or location regexp "#{requests_for_work}"))
    end

    def influencer
      media = '[Yy]ou[Tt]ube|[Ii]nstagram|[Tt]ik[Tt]ok'
      where(%Q(followers_count > 10000 and friends_count < followers_count and (description regexp "#{media}" or url regexp "#{media}")))
    end

    def lawyer
      where('description regexp "弁護士|lawyer|attorney"')
    end

    def public_accountant
      where('description regexp "会計士|(public\s+accountant)"')
    end

    def tax_accountant
      where('description regexp "税理士|(tax\s+accountant)"')
    end

    def entrepreneur
      where('description regexp "起業"')
    end

    def investor
      where('description regexp "投資|Founder|ベンチャーキャピタル|VC|アーリーステージ|インキュベータ|インキュベーション"')
    end

    def designer
      where('description regexp "([Dd])esigner|デザイナ|イラストレータ"')
    end

    def artist
      where('description regexp "絵描き|日本画|油画|彫塑"')
    end

    def bikini_model
      where('description regexp "グラビア|グラドル"')
    end

    def fashion_model
      where('description regexp "モデル"')
    end

    def pop_idol
      where('description regexp "アイドル"')
    end

    def general_student
      where('description regexp "学生"')
    end

    def high_school_student
      where('description regexp "高校生|高[1-3]|(fsl)jk"')
    end

    US_UNIV = '[Hh]arvard|[Ss]tanford|UCB|ucb|UCLA|ucla|MIT|mit|CMU|cmu'
    JP_UNIV = '大学生|(東京|一橋|お茶の水女子|東京外国語|東京都立|東京芸術|東京学芸|東京工業|東京医科歯科|東京農工|東京海洋|電気通信|早稲田|慶[応應]義塾|国際基督教|上智|立教|中央|明治|青山学院|法政|学習院|成蹊|日本女子|武蔵|[国國][学學]院|東京理科|明治学院|津田塾|東洋|駒[沢澤]|東京女子|昭和女子|大妻女子|東京家政|清泉女子)大学?'

    def college_student
      where(%Q(description regexp "#{US_UNIV}|#{JP_UNIV}"))
    end

    def order_by_field(uids)
      order(Arel.sql("field(uid, #{uids.join(',')})"))
    end
  end
end

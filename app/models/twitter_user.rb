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

    def search_url(str)
      where('url like ?', "%#{sanitize_sql_like(str)}%")
    end

    def search_description(str)
      where('description like ?', "%#{sanitize_sql_like(str)}%")
    end

    def engineer
      where('description regexp "([Ee])ngineer|エンジニア|開発者|Python|Ruby|Golang|Java"')
    end

    def freelancer
      where('description regexp "([Ff])reelance|フリーランス|(仕事.+依頼)"')
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

    def model_or_idol
      where('description regexp "グラビア|モデル|アイドル"')
    end

    def high_school_student
      where('description regexp "高[1-3]|(fsl)jk"')
    end

    def college_student
      where('description regexp "(東京|一橋|お茶の水女子|東京外国語|東京都立|東京芸術|東京学芸|東京工業|東京医科歯科|東京農工|東京海洋|電気通信|早稲田|慶[応應]義塾|国際基督教|上智|立教|中央|明治|青山学院|法政|学習院|成蹊|日本女子|武蔵|[国國][学學]院|東京理科|明治学院|津田塾|東洋|駒[沢澤]|東京女子|昭和女子|大妻女子|東京家政|清泉女子)大学?"')
    end

    def order_by_field(uids)
      order(Arel.sql("field(uid, #{uids.join(',')})"))
    end
  end
end

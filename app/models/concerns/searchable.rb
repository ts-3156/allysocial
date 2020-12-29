require 'active_support/concern'

module Searchable
  extend ActiveSupport::Concern

  class_methods do
  end

  def users
    @users ||= (properties['users'] || []).map { |user| User.new(user) }
  end

  def select_users_by_job(value)
    users.select { |user| user.match_job?(value) }
  end

  def select_users_by_location(value)
    users.select { |user| user.match_location?(value) }
  end

  def select_users_by_keyword(value)
    users.select { |user| user.match_description?(value) }
  end

  JOB_QUERIES = %w(
    lawyer
    public_accountant
    tax_accountant
    entrepreneur
    investor
    engineer
    designer
    artist
    model_or_idol
    high_school_student
    college_student
  )

  JOB_LABELS = {
    en: {
      lawyer: 'Lawyer',
      public_accountant: 'Public accountant',
      tax_accountant: 'Tax accountant',
      entrepreneur: 'Entrepreneur',
      investor: 'Investor',
      engineer: 'Engineer',
      designer: 'Designer',
      artist: 'Artist',
      model_or_idol: 'Model or idol',
      high_school_student: 'High school student',
      college_student: 'College student',
    },
    ja: {
      lawyer: '弁護士',
      public_accountant: '会計士',
      tax_accountant: '税理士',
      entrepreneur: '起業家',
      investor: '投資家',
      engineer: 'エンジニア',
      designer: 'デザイナー',
      artist: 'アーティスト',
      model_or_idol: 'モデルまたはアイドル',
      high_school_student: '高校生',
      college_student: '大学生',
    }
  }

  class User
    def initialize(attrs)
      @attrs = attrs
    end

    def location
      @attrs['location']
    end

    def match_location?(query)
      if query.match?(/[, ]/)
        query.split(/[, ]/).all? { |str| location&.include?(str) }
      else
        location&.include?(query)
      end
    end

    def description
      @attrs['description']
    end

    def match_description?(query)
      description&.include?(query)
    end

    def match_job?(query)
      if JOB_QUERIES.include?(query)
        send("#{query}?")
      else
        false
      end
    end

    def lawyer?
      @attrs['description']&.match?(/弁護士|lawyer|attorney/)
    end

    def public_accountant?
      @attrs['description']&.match?(/会計士|(public\s+accountant)/)
    end

    def tax_accountant?
      @attrs['description']&.match?(/税理士|(tax\s+accountant)/)
    end

    def entrepreneur?
      @attrs['description']&.match?(/起業/)
    end

    def investor?
      @attrs['description']&.match?(/投資|Founder|ベンチャーキャピタル|VC|アーリーステージ|インキュベータ|インキュベーション/)
    end

    def engineer?
      @attrs['description']&.match?(/([Ee])ngineer|エンジニア|開発者|Python|Ruby|Golang|Java/)
    end

    def designer?
      @attrs['description']&.match?(/([Dd])esigner|デザイナ|イラストレータ/)
    end

    def artist?
      @attrs['description']&.match?(/絵描き|日本画|油画|彫塑/)
    end

    def model_or_idol?
      @attrs['description']&.match?(/グラビア|モデル|アイドル/)
    end

    def high_school_student?
      @attrs['description']&.match?(/高[1-3]|(fsl)jk/)
    end

    def college_student?
      @attrs['description']&.match?(/(東京|一橋|お茶の水女子|東京外国語|東京都立|東京芸術|東京学芸|東京工業|東京医科歯科|東京農工|東京海洋|電気通信|早稲田|慶[応應]義塾|国際基督教|上智|立教|中央|明治|青山学院|法政|学習院|成蹊|日本女子|武蔵|[国國][学學]院|東京理科|明治学院|津田塾|東洋|駒[沢澤]|東京女子|昭和女子|大妻女子|東京家政|清泉女子)大学?/)
    end

    def to_hash
      @attrs.dup
    end
  end

end

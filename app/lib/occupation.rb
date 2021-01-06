class Occupation
  def initialize(attrs)
    @attrs = attrs
  end

  def description
    @attrs[:description] || ''
  end

  def url
    @attrs[:url] || ''
  end

  def location
    @attrs[:location] || ''
  end

  def friends_count
    @attrs[:friends_count] || 0
  end

  def followers_count
    @attrs[:followers_count] || 0
  end

  def detect_title
    self.class.job_detector_methods.map do |method_name|
      if send("#{method_name}?")
        return method_name
      end
    end
    'not_applicable'
  end

  def self.method_added(method_name)
    # Want to fix the order
    @job_detector_methods ||= []
    if method_name.to_s.match?(/\?$/)
      @job_detector_methods << method_name.to_s.delete_suffix('?')
    end
  end

  def self.job_detector_methods
    @job_detector_methods
  end

  YOUTUBER_KEYWORDS = '[Yy]ou[Tt]uber|ユーチューバ'

  def youtuber?
    regexp = Regexp.new(YOUTUBER_KEYWORDS)
    description.match?(regexp) || url.match?(regexp)
  end

  def self.youtuber(model)
    model.where(%Q(description regexp "#{YOUTUBER_KEYWORDS}" or url regexp "#{YOUTUBER_KEYWORDS}"))
  end

  ENGINEER_KEYWORDS = '([Ee])ngineer|[Pp]rogramming|[Pp]rogrammer|エンジニア|プログラマ|プログラミング|開発者|Python|Ruby|Golang|Java|Scala|Android|iOS'

  def engineer?
    description.match?(Regexp.new(ENGINEER_KEYWORDS))
  end

  def self.engineer(model)
    model.where(%Q(description regexp "#{ENGINEER_KEYWORDS}"))
  end

  FREELANCER_KEYWORDS = '([Ff])reelance|フリーランス|(仕事.*(依頼|募集|相談))|(依頼.+DM)|ご?連絡は'

  def freelancer?
    regexp = Regexp.new(FREELANCER_KEYWORDS)
    description.match?(regexp) || location.match?(regexp)
  end

  def self.freelancer(model)
    model.where(%Q(description regexp "#{FREELANCER_KEYWORDS}" or location regexp "#{FREELANCER_KEYWORDS}"))
  end

  INFLUENCER_KEYWORDS = '[Yy]ou[Tt]ube|[Ii]nstagram|[Tt]ik[Tt]ok'

  def influencer?
    regexp = Regexp.new(INFLUENCER_KEYWORDS)
    followers_count > 10000 && friends_count < followers_count && (description.match?(regexp) || url.match?(regexp))
  end

  def self.influencer(model)
    model.where(%Q(followers_count > 10000 and friends_count < followers_count and (description regexp "#{INFLUENCER_KEYWORDS}" or url regexp "#{INFLUENCER_KEYWORDS}")))
  end

  LAWYER_KEYWORDS = '弁護士|lawyer|attorney'

  def lawyer?
    description.match?(Regexp.new(LAWYER_KEYWORDS))
  end

  def self.lawyer(model)
    model.where(%Q(description regexp "#{LAWYER_KEYWORDS}"))
  end

  PUBLIC_ACCOUNTANT_KEYWORDS = '会計士|(public\s+accountant)'

  def public_accountant?
    description.match?(Regexp.new(PUBLIC_ACCOUNTANT_KEYWORDS))
  end

  def self.public_accountant(model)
    model.where(%Q(description regexp "#{PUBLIC_ACCOUNTANT_KEYWORDS}"))
  end

  TAX_ACCOUNTANT_KEYWORDS = '税理士|(tax\s+accountant)'

  def tax_accountant?
    description.match?(Regexp.new(TAX_ACCOUNTANT_KEYWORDS))
  end

  def self.tax_accountant(model)
    model.where(%Q(description regexp "#{TAX_ACCOUNTANT_KEYWORDS}"))
  end

  ENTREPRENEUR_KEYWORDS = '起業'

  def entrepreneur?
    description.match?(Regexp.new(ENTREPRENEUR_KEYWORDS))
  end

  def self.entrepreneur(model)
    model.where(%Q(description regexp "#{ENTREPRENEUR_KEYWORDS}"))
  end

  INVESTOR_KEYWORDS = '投資|Founder|ベンチャーキャピタル|VC|アーリーステージ|インキュベータ|インキュベーション'

  def investor?
    description.match?(Regexp.new(INVESTOR_KEYWORDS))
  end

  def self.investor(model)
    model.where(%Q(description regexp "#{INVESTOR_KEYWORDS}"))
  end

  EXCHANGE_TRADER_KEYWORDS = '[Tt]rader|トレーダ'

  def exchange_trader?
    description.match?(Regexp.new(EXCHANGE_TRADER_KEYWORDS))
  end

  def self.exchange_trader(model)
    model.where(%Q(description regexp "#{EXCHANGE_TRADER_KEYWORDS}"))
  end

  POLITICIAN_KEYWORDS = '議員|大臣'

  def politician?
    friends_count < followers_count && description.match?(Regexp.new(POLITICIAN_KEYWORDS))
  end

  def self.politician(model)
    model.where(%Q(description regexp "#{POLITICIAN_KEYWORDS}" and friends_count < followers_count))
  end

  POLITICAL_ACTIVIST_KEYWORDS = '政治|憲法'

  def political_activist?
    description.match?(Regexp.new(POLITICAL_ACTIVIST_KEYWORDS)) && !description.match?(Regexp.new(POLITICIAN_KEYWORDS))
  end

  def self.political_activist(model)
    model.where(%Q(description regexp "#{POLITICAL_ACTIVIST_KEYWORDS}" and description not regexp "#{POLITICIAN_KEYWORDS}"))
  end

  DESIGNER_KEYWORDS = '([Dd])esigner|デザイナ'

  def designer?
    description.match?(Regexp.new(DESIGNER_KEYWORDS))
  end

  def self.designer(model)
    model.where(%Q(description regexp "#{DESIGNER_KEYWORDS}"))
  end

  ILLUSTRATOR_KEYWORDS = '([Ii])llustrator|イラストレータ'

  def illustrator?
    description.match?(Regexp.new(ILLUSTRATOR_KEYWORDS))
  end

  def self.illustrator(model)
    model.where(%Q(description regexp "#{ILLUSTRATOR_KEYWORDS}"))
  end

  PAINTER_KEYWORDS = 'painter|絵描き|画家|油(絵|画)|日本画|oil\s+paint'

  def painter?
    description.match?(Regexp.new(PAINTER_KEYWORDS))
  end

  def self.painter(model)
    model.where(%Q(description regexp "#{PAINTER_KEYWORDS}"))
  end

  SCULPTOR_KEYWORDS = 'sculptor|sculptor|彫塑|彫刻'

  def sculptor?
    description.match?(Regexp.new(SCULPTOR_KEYWORDS))
  end

  def self.sculptor(model)
    model.where(%Q(description regexp "#{SCULPTOR_KEYWORDS}"))
  end

  CRAFTSPERSON_KEYWORDS = '工芸(.+職人)?'

  def craftsperson?
    description.match?(Regexp.new(CRAFTSPERSON_KEYWORDS))
  end

  def self.craftsperson(model)
    model.where(%Q(description regexp "#{CRAFTSPERSON_KEYWORDS}"))
  end

  WOODWORKER_KEYWORDS = '木工(.+職人)?'

  def woodworker?
    description.match?(Regexp.new(WOODWORKER_KEYWORDS))
  end

  def self.woodworker(model)
    model.where(%Q(description regexp "#{WOODWORKER_KEYWORDS}"))
  end

  PHOTOGRAPHER_KEYWORDS = '写真家|[Pp]hotographer'

  def photographer?
    description.match?(Regexp.new(PHOTOGRAPHER_KEYWORDS))
  end

  def self.photographer(model)
    model.where(%Q(description regexp "#{PHOTOGRAPHER_KEYWORDS}"))
  end

  MANGA_ARTIST_KEYWORDS = '漫画家|連載中'

  def manga_artist?
    description.match?(Regexp.new(MANGA_ARTIST_KEYWORDS))
  end

  def self.manga_artist(model)
    model.where(%Q(description regexp "#{MANGA_ARTIST_KEYWORDS}"))
  end

  GENERAL_ARTIST_KEYWORDS = '美術家|芸術家'

  def general_artist?
    description.match?(Regexp.new(GENERAL_ARTIST_KEYWORDS))
  end

  def self.general_artist(model)
    model.where(%Q(description regexp "#{GENERAL_ARTIST_KEYWORDS}"))
  end

  CRITIC_KEYWORDS = '評論家|コメンテータ'

  def critic?
    description.match?(Regexp.new(CRITIC_KEYWORDS))
  end

  def self.critic(model)
    model.where(%Q(description regexp "#{CRITIC_KEYWORDS}"))
  end

  WRITER_KEYWORDS = 'writer|連載中'

  def writer?
    description.match?(Regexp.new(WRITER_KEYWORDS))
  end

  def self.writer(model)
    model.where(%Q(description regexp "#{WRITER_KEYWORDS}"))
  end

  REPORTER_KEYWORDS = '[Rr]eporter|レポータ'

  def reporter?
    description.match?(Regexp.new(REPORTER_KEYWORDS))
  end

  def self.reporter(model)
    model.where(%Q(description regexp "#{REPORTER_KEYWORDS}"))
  end

  BLOGGER_KEYWORDS = '[Bb]logger|ブロガ'

  def blogger?
    description.match?(Regexp.new(BLOGGER_KEYWORDS))
  end

  def self.blogger(model)
    model.where(%Q(description regexp "#{BLOGGER_KEYWORDS}"))
  end

  CULINARY_RESEARCHER_KEYWORDS = '料理研究家|料理人|レシピ'

  def culinary_researcher?
    description.match?(Regexp.new(CULINARY_RESEARCHER_KEYWORDS))
  end

  def self.culinary_researcher(model)
    model.where(%Q(description regexp "#{CULINARY_RESEARCHER_KEYWORDS}"))
  end

  COMEDIAN_KEYWORDS = 'NSC.+\d+期'

  def comedian?
    description.match?(Regexp.new(COMEDIAN_KEYWORDS))
  end

  def self.comedian(model)
    model.where(%Q(description regexp "#{COMEDIAN_KEYWORDS}"))
  end

  BIKINI_MODEL_KEYWORDS = 'グラビア|グラドル'

  def bikini_model?
    description.match?(Regexp.new(BIKINI_MODEL_KEYWORDS))
  end

  def self.bikini_model(model)
    model.where(%Q(description regexp "#{BIKINI_MODEL_KEYWORDS}"))
  end

  FASHION_MODEL_KEYWORDS = 'モデル'

  def fashion_model?
    description.match?(Regexp.new(FASHION_MODEL_KEYWORDS))
  end

  def self.fashion_model(model)
    model.where(%Q(description regexp "#{FASHION_MODEL_KEYWORDS}"))
  end

  POP_IDOL_KEYWORDS = 'アイドル'

  def pop_idol?
    description.match?(Regexp.new(POP_IDOL_KEYWORDS))
  end

  def self.pop_idol(model)
    model.where(%Q(description regexp "#{POP_IDOL_KEYWORDS}"))
  end

  CONCAFE_WAITRESS_KEYWORDS = 'コンカフェ'

  def concafe_waitress?
    description.match?(Regexp.new(CONCAFE_WAITRESS_KEYWORDS))
  end

  def self.concafe_waitress(model)
    model.where(%Q(description regexp "#{CONCAFE_WAITRESS_KEYWORDS}"))
  end

  GIRLS_BAR_WAITRESS_KEYWORDS = 'ガールズバー'

  def girls_bar_waitress?
    description.match?(Regexp.new(GIRLS_BAR_WAITRESS_KEYWORDS))
  end

  def self.girls_bar_waitress(model)
    model.where(%Q(description regexp "#{GIRLS_BAR_WAITRESS_KEYWORDS}"))
  end

  MIGRANT_WORKER_KEYWORDS = '出稼ぎ'

  def migrant_worker?
    description.match?(Regexp.new(MIGRANT_WORKER_KEYWORDS))
  end

  def self.migrant_worker(model)
    model.where(%Q(description regexp "#{MIGRANT_WORKER_KEYWORDS}"))
  end

  NIGHTLIFE_BUSINESS_KEYWORDS = '夜職|ソープ[^カ]|そーぷらんど|メンエス嬢|風俗嬢|風俗店| #風俗 |泡姫|ホテヘル|箱ヘル|デリヘル|パパ活|ママ活|性感エステ|性感ヘルス|性感マッサージ'

  def nightlife_business?
    description.match?(Regexp.new(NIGHTLIFE_BUSINESS_KEYWORDS))
  end

  def self.nightlife_business(model)
    model.where(%Q(description regexp "#{NIGHTLIFE_BUSINESS_KEYWORDS}"))
  end

  PART_TIMER_KEYWORDS = '(アル)?バイト'

  def part_timer?
    description.match?(Regexp.new(PART_TIMER_KEYWORDS))
  end

  def self.part_timer(model)
    model.where(%Q(description regexp "#{PART_TIMER_KEYWORDS}"))
  end

  GENERAL_STUDENT_KEYWORDS = '[Ss]tudent|学生|年生|休学'

  def general_student?
    description.match?(Regexp.new(PART_TIMER_KEYWORDS))
  end

  def self.general_student(model)
    model.where(%Q(description regexp "#{PART_TIMER_KEYWORDS}"))
  end

  HIGH_SCHOOL_STUDENT_KEYWORDS = '高校生|高[1-3]|(fsl)jk'

  def high_school_student?
    description.match?(Regexp.new(HIGH_SCHOOL_STUDENT_KEYWORDS))
  end

  def self.high_school_student(model)
    model.where(%Q(description regexp "#{HIGH_SCHOOL_STUDENT_KEYWORDS}"))
  end

  JP_ART_UNIV = '(東京(藝|芸)術|多摩美術|武蔵野美術|金沢美術工芸|京都市立芸術|愛知県立芸術|東京造形|女子美術|学芸)大学?|(芸術|美術).*大学|芸術専門学群|(藝|芸)大|美大|多摩美|たまび|むさび'

  def art_student?
    description.match?(Regexp.new(JP_ART_UNIV))
  end

  def self.art_student(model)
    model.where(%Q(description regexp "#{JP_ART_UNIV}"))
  end

  US_UNIV = '[Hh]arvard|[Ss]tanford|UCB|ucb|UCLA|ucla|MIT|mit|CMU|cmu'
  JP_UNIV = '大学生|(東京|一橋|お茶の水女子|東京外国語|東京都立|東京芸術|東京学芸|東京工業|東京医科歯科|東京農工|東京海洋|電気通信|早稲田|慶[応應]義塾|国際基督教|上智|立教|中央|明治|青山学院|法政|学習院|成蹊|日本女子|武蔵|[国國][学學]院|東京理科|明治学院|津田塾|東洋|駒[沢澤]|東京女子|昭和女子|大妻女子|東京家政|清泉女子)大学?'

  def college_student?
    description.match?(Regexp.new("#{US_UNIV}|#{JP_UNIV}"))
  end

  def self.college_student(model)
    model.where(%Q(description regexp "#{US_UNIV}|#{JP_UNIV}"))
  end

  OFFICIAL_ACCOUNT_KEYWORDS = '公式([Tt]witter|ツイッター)?アカウント'

  def official_account?
    friends_count < followers_count && description.match?(Regexp.new(OFFICIAL_ACCOUNT_KEYWORDS))
  end

  def self.official_account(model)
    model.where(%Q(friends_count < followers_count and description regexp "#{OFFICIAL_ACCOUNT_KEYWORDS}"))
  end

  BOT_KEYWORDS = '[^o][Bb]ot|[^ロ]ボット'

  def bot?
    description.match?(Regexp.new(BOT_KEYWORDS))
  end

  def self.bot(model)
    model.where(%Q(description regexp "#{BOT_KEYWORDS}"))
  end

  JOBLESS_KEYWORDS = '[Jj]obless|[Uu]nemployed|[Nn]o\s+job|無職'

  def jobless?
    description.match?(Regexp.new(JOBLESS_KEYWORDS))
  end

  def self.jobless(model)
    model.where(%Q(description regexp "#{JOBLESS_KEYWORDS}"))
  end
end

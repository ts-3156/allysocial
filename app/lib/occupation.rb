class Occupation
  def initialize(attrs)
    @attrs = attrs
  end

  def name
    @attrs[:name] || ''
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

  def job_key
    job_keys(1)[0]
  end

  def job_keys(count = 3)
    found = []
    self.class.job_detector_methods.map do |method_name|
      found << method_name if send("#{method_name}?")
      break if found.size >= count
    end
    found.size >= 1 ? found.take(count) : ['not_applicable']
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

  ENGINEER_KEYWORDS = '([Ee])ngineer|[Pp]rogramming|[Pp]rogrammer|エンジニア|プログラマ|プログラミング|開発者|個人開発|Python|Ruby|Golang|Java|Scala|Android|iOS'

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

  JUDICIAL_SCRIVENER_KEYWORDS = '司法書士'

  def judicial_scrivener?
    description.match?(Regexp.new(JUDICIAL_SCRIVENER_KEYWORDS))
  end

  def self.judicial_scrivener(model)
    model.where(%Q(description regexp "#{JUDICIAL_SCRIVENER_KEYWORDS}"))
  end

  ADMINISTRATIVE_SCRIVENER_KEYWORDS = '行政書士'

  def administrative_scrivener?
    description.match?(Regexp.new(ADMINISTRATIVE_SCRIVENER_KEYWORDS))
  end

  def self.administrative_scrivener(model)
    model.where(%Q(description regexp "#{ADMINISTRATIVE_SCRIVENER_KEYWORDS}"))
  end

  PUBLIC_ACCOUNTANT_KEYWORDS = '会計士|(public\s+accountant)'
  PUBLIC_ACCOUNTANT_KEYWORDS_DB = '会計士|(public[[:space:]]+accountant)'

  def public_accountant?
    description.match?(Regexp.new(PUBLIC_ACCOUNTANT_KEYWORDS))
  end

  def self.public_accountant(model)
    model.where(%Q(description regexp "#{PUBLIC_ACCOUNTANT_KEYWORDS_DB}"))
  end

  TAX_ACCOUNTANT_KEYWORDS = '税理士|[Tt]ax\s+accountant'
  TAX_ACCOUNTANT_KEYWORDS_DB = '税理士|[Tt]ax[[:space:]]+accountant'

  def tax_accountant?
    regexp = Regexp.new(TAX_ACCOUNTANT_KEYWORDS)
    name.match?(regexp) || description.match?(regexp)
  end

  def self.tax_accountant(model)
    model.where(%Q(name regexp "#{TAX_ACCOUNTANT_KEYWORDS_DB}" or description regexp "#{TAX_ACCOUNTANT_KEYWORDS_DB}"))
  end

  ENTREPRENEUR_KEYWORDS = '起業'

  def entrepreneur?
    description.match?(Regexp.new(ENTREPRENEUR_KEYWORDS))
  end

  def self.entrepreneur(model)
    model.where(%Q(description regexp "#{ENTREPRENEUR_KEYWORDS}"))
  end

  EXECUTIVE_OFFICER_KEYWORDS = '代表取締役|社長|CEO|COO'

  def executive_officer?
    description.match?(Regexp.new(EXECUTIVE_OFFICER_KEYWORDS))
  end

  def self.executive_officer(model)
    model.where(%Q(cast(description as binary) regexp binary "#{EXECUTIVE_OFFICER_KEYWORDS}"))
  end

  EMPLOYEE_KEYWORDS = '[Ee]mployee|会社員'

  def employee?
    description.match?(Regexp.new(EMPLOYEE_KEYWORDS))
  end

  def self.employee(model)
    model.where(%Q(description regexp "#{EMPLOYEE_KEYWORDS}"))
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

  PROFESSOR_KEYWORDS = '[Pp]rofessor|教授'

  def professor?
    description.match?(Regexp.new(PROFESSOR_KEYWORDS))
  end

  def self.professor(model)
    model.where(%Q(description regexp "#{PROFESSOR_KEYWORDS}"))
  end

  TEACHER_KEYWORDS = '[Tt]eacher|教員|教師|先生|講師'

  def teacher?
    description.match?(Regexp.new(TEACHER_KEYWORDS))
  end

  def self.teacher(model)
    model.where(%Q(description regexp "#{TEACHER_KEYWORDS}"))
  end

  DESIGNER_KEYWORDS = '([Dd])esigner|デザイナ'

  def designer?
    description.match?(Regexp.new(DESIGNER_KEYWORDS))
  end

  def self.designer(model)
    model.where(%Q(description regexp "#{DESIGNER_KEYWORDS}"))
  end

  ILLUSTRATOR_KEYWORDS = '([Ii])llustrator|[Pp]ixiv|イラストレータ|イラスト作家|描いています|描きます|絵を描く'

  def illustrator?
    description.match?(Regexp.new(ILLUSTRATOR_KEYWORDS))
  end

  def self.illustrator(model)
    model.where(%Q(description regexp "#{ILLUSTRATOR_KEYWORDS}"))
  end

  PAINTER_KEYWORDS = '[Pp]ainter|絵描き|画家|油(絵|画)|日本画|[Oo]il\s+paint'
  PAINTER_KEYWORDS_DB = '[Pp]ainter|絵描き|画家|油(絵|画)|日本画|[Oo]il[[:space:]]+paint'

  def painter?
    description.match?(Regexp.new(PAINTER_KEYWORDS))
  end

  def self.painter(model)
    model.where(%Q(description regexp "#{PAINTER_KEYWORDS_DB}"))
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

  PHOTOGRAPHER_KEYWORDS = '[Pp]hotographer|写真家|フォトグラファ'

  def photographer?
    description.match?(Regexp.new(PHOTOGRAPHER_KEYWORDS))
  end

  def self.photographer(model)
    model.where(%Q(description regexp "#{PHOTOGRAPHER_KEYWORDS}"))
  end

  MANGA_ARTIST_KEYWORDS = '漫画家|連載中|単行本|作画'

  def manga_artist?
    description.match?(Regexp.new(MANGA_ARTIST_KEYWORDS))
  end

  def self.manga_artist(model)
    model.where(%Q(description regexp "#{MANGA_ARTIST_KEYWORDS}"))
  end

  GENERAL_ARTIST_KEYWORDS = '美術家|芸術家|アーティスト'

  def general_artist?
    description.match?(Regexp.new(GENERAL_ARTIST_KEYWORDS))
  end

  def self.general_artist(model)
    model.where(%Q(description regexp "#{GENERAL_ARTIST_KEYWORDS}"))
  end

  DO_IT_YOURSELFER_KEYWORDS = 'DIY|(モノ|もの)(づく|作)り'

  def do_it_yourselfer?
    description.match?(Regexp.new(DO_IT_YOURSELFER_KEYWORDS))
  end

  def self.do_it_yourselfer(model)
    model.where(%Q(description regexp "#{DO_IT_YOURSELFER_KEYWORDS}"))
  end

  CRITIC_KEYWORDS = '評論家|コメンテータ'

  def critic?
    description.match?(Regexp.new(CRITIC_KEYWORDS))
  end

  def self.critic(model)
    model.where(%Q(description regexp "#{CRITIC_KEYWORDS}"))
  end

  WRITER_KEYWORDS = '[Ww]riter|ライター|連載中|著者|著書|書籍|刊行'

  def writer?
    description.match?(Regexp.new(WRITER_KEYWORDS))
  end

  def self.writer(model)
    model.where(%Q(description regexp "#{WRITER_KEYWORDS}"))
  end

  EDITOR_KEYWORDS = '[Ee]ditor|編集者'

  def editor?
    description.match?(Regexp.new(EDITOR_KEYWORDS))
  end

  def self.editor(model)
    model.where(%Q(description regexp "#{EDITOR_KEYWORDS}"))
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

  COMEDIAN_KEYWORDS = 'NSC.*\d+期'
  COMEDIAN_KEYWORDS_DB = 'NSC.*[[:digit:]]+期'

  def comedian?
    description.match?(Regexp.new(COMEDIAN_KEYWORDS))
  end

  def self.comedian(model)
    model.where(%Q(description regexp "#{COMEDIAN_KEYWORDS_DB}"))
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

  PRODUCER_KEYWORDS = '[Pp]roducer|プロデューサ|プロデュース'

  def producer?
    description.match?(Regexp.new(PRODUCER_KEYWORDS))
  end

  def self.producer(model)
    model.where(%Q(description regexp "#{PRODUCER_KEYWORDS}"))
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

  HIGH_SCHOOL_STUDENT_KEYWORDS = '高校生|高[1-3]|[FSL]JK|[fsl]jk|JK[1-3]|jk[1-3]'

  def high_school_student?
    description.match?(Regexp.new(HIGH_SCHOOL_STUDENT_KEYWORDS))
  end

  def self.high_school_student(model)
    model.where(%Q(description regexp "#{HIGH_SCHOOL_STUDENT_KEYWORDS}"))
  end

  MIDDLE_SCHOOL_STUDENT_KEYWORDS = '中学生|中[1-3]|[FSL]JC|[fsl]jc|JC[1-3]|jc[1-3]'

  def middle_school_student?
    description.match?(Regexp.new(MIDDLE_SCHOOL_STUDENT_KEYWORDS))
  end

  def self.middle_school_student(model)
    model.where(%Q(description regexp "#{MIDDLE_SCHOOL_STUDENT_KEYWORDS}"))
  end

  JP_ART_UNIV = '(東京(藝|芸)術|多摩美術|武蔵野美術|金沢美術工芸|京都市立芸術|愛知県立芸術|東京造形|女子美術|学芸)大学?|(芸術|美術).*大学|芸術専門学群|(藝|芸)大|美大|多摩美|たまび|タマビ|むさび|ムサビ'

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

  DOCTOR_OF_PHILOSOPHY_KEYWORDS = 'Ph\.?D|D\.Phil'
  DOCTOR_OF_PHILOSOPHY_KEYWORDS_DB = 'Ph\\.?D|D\\.Phil'

  def doctor_of_philosophy?
    description.match?(Regexp.new(DOCTOR_OF_PHILOSOPHY_KEYWORDS))
  end

  def self.doctor_of_philosophy(model)
    model.where(%Q(description regexp "#{DOCTOR_OF_PHILOSOPHY_KEYWORDS_DB}"))
  end

  OFFICIAL_ACCOUNT_KEYWORDS = '公式([Tt]witter|ツイッター)?アカウント'

  def official_account?
    friends_count < followers_count && description.match?(Regexp.new(OFFICIAL_ACCOUNT_KEYWORDS))
  end

  def self.official_account(model)
    model.where(%Q(friends_count < followers_count and description regexp "#{OFFICIAL_ACCOUNT_KEYWORDS}"))
  end

  GAMER_KEYWORDS = '[Aa]pex|Splatoon|スプラトゥーン|パズドラ|モンスト|フォートナイト|フォトナ|荒野行動|ヒプマイ|ドラクエ|ポケモン|スマブラ|マイクラ|あつ森|人狼'

  def gamer?
    description.match?(Regexp.new(GAMER_KEYWORDS))
  end

  def self.gamer(model)
    model.where(%Q(description regexp "#{GAMER_KEYWORDS}"))
  end

  HOBBYIST_KEYWORDS = '無言フォロー|フォロバ|ブロ解|空リプ|リア友|ツイ消し|雑多垢|鍵垢|裏垢|推し|推せ|ニコニコ動画|wishlist|下ネタ'

  def hobbyist?
    description.match?(Regexp.new(HOBBYIST_KEYWORDS))
  end

  def self.hobbyist(model)
    model.where(%Q(description regexp "#{HOBBYIST_KEYWORDS}"))
  end

  BOT_KEYWORDS = '[^o][Bb]ot|[^ロ]ボット'

  def bot?
    description.match?(Regexp.new(BOT_KEYWORDS))
  end

  def self.bot(model)
    model.where(%Q(description regexp "#{BOT_KEYWORDS}"))
  end

  JOBLESS_KEYWORDS = '[Jj]obless|[Uu]nemployed|[Nn]o\s+job|無職'
  JOBLESS_KEYWORDS_DB = '[Jj]obless|[Uu]nemployed|[Nn]o[[:space:]]+job|無職'

  def jobless?
    description.match?(Regexp.new(JOBLESS_KEYWORDS))
  end

  def self.jobless(model)
    model.where(%Q(description regexp "#{JOBLESS_KEYWORDS_DB}"))
  end
end

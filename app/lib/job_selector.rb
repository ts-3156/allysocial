class JobSelector < BaseSelector
  class << self
    def fixed_values
      []
    end

    def fixed_labels
      {
        en: {
          youtuber: 'YouTuber',
          engineer: 'Engineer',
          freelancer: 'Freelancer',
          influencer: 'Influencer',
          lawyer: 'Lawyer',
          public_accountant: 'Public accountant',
          tax_accountant: 'Tax accountant',
          entrepreneur: 'Entrepreneur',
          investor: 'Investor',
          exchange_trader: 'Exchange trader',
          politician: 'Politician',
          political_activist: 'Political activist',
          professor: 'Professor',
          teacher: 'Teacher',
          designer: 'Designer',
          illustrator: 'Illustrator',
          painter: 'Painter',
          sculptor: 'Sculptor',
          craftsperson: 'Craftsperson',
          woodworker: 'Woodworker',
          photographer: 'Photographer',
          manga_artist: 'Manga artist',
          general_artist: 'General artist',
          do_it_yourselfer: 'DIYer',
          critic: 'Critic',
          writer: 'Writer',
          editor: 'Editor',
          reporter: 'Reporter',
          blogger: 'Blogger',
          culinary_researcher: 'Culinary researcher',
          comedian: 'Comedian',
          bikini_model: 'Bikini model',
          fashion_model: 'Fashion model',
          pop_idol: 'Pop idol',
          producer: 'Producer',
          concafe_waitress: 'Concafe waitress',
          girls_bar_waitress: "girl's bar waitress",
          migrant_worker: 'Migrant worker',
          nightlife_business: 'Nightlife business',
          part_timer: 'Part timer',
          general_student: 'General student',
          art_student: 'Art student',
          college_student: 'College student',
          high_school_student: 'High school student',
          official_account: 'Official account',
          bot: 'Bot',
          jobless: 'Jobless',
          not_applicable: 'Others',
        },
        ja: {
          youtuber: 'YouTuber',
          engineer: 'エンジニア',
          freelancer: 'フリーランス',
          influencer: 'インフルエンサー',
          lawyer: '弁護士',
          public_accountant: '会計士',
          tax_accountant: '税理士',
          entrepreneur: '起業家',
          investor: '投資家',
          exchange_trader: 'トレーダー',
          politician: '政治家',
          political_activist: '政治活動家',
          professor: '大学教員',
          teacher: '学校教師',
          designer: 'デザイナー',
          illustrator: 'イラストレーター',
          painter: '画家',
          sculptor: '彫刻家',
          craftsperson: '工芸職人',
          woodworker: '木工職人',
          photographer: '写真家',
          manga_artist: '漫画家',
          general_artist: '芸術家',
          do_it_yourselfer: '日曜大工',
          critic: '評論家',
          writer: '作家',
          editor: '編集者',
          reporter: 'レポーター',
          blogger: 'ブロガー',
          culinary_researcher: '料理研究家',
          comedian: 'お笑い芸人',
          bikini_model: 'グラビアモデル',
          fashion_model: 'ファッションモデル',
          pop_idol: 'ポップアイドル',
          producer: 'プロデューサー',
          concafe_waitress: 'コンカフェ',
          girls_bar_waitress: 'ガールズバー',
          migrant_worker: '出稼ぎ',
          nightlife_business: '夜職',
          part_timer: 'アルバイト',
          general_student: '一般学生',
          art_student: '美大生',
          college_student: '大学生',
          high_school_student: '高校生',
          official_account: '公式アカウント',
          bot: 'ボット',
          jobless: '無職',
          not_applicable: 'その他',
        }
      }
    end
  end

  def select_options
    extracted_options = options_from_words(@insight.job_words)
    quick_select = extracted_options.take(3)
    [extracted_options, quick_select]
  end

  class << self
    def label_to_value(raw_label)
      fixed_labels.each do |_, values|
        values.each do |key, label|
          return key if raw_label == label
        end
      end
      nil
    end
  end
end

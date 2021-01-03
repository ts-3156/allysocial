class JobSelector
  LABELS = {
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
      politician: 'Politician',
      political_activist: 'Political activist',
      designer: 'Designer',
      illustrator: 'Illustrator',
      painter: 'Painter',
      sculptor: 'Sculptor',
      photographer: 'Photographer',
      manga_artist: 'Manga artist',
      writer: 'Writer',
      culinary_researcher: 'Culinary researcher',
      comedian: 'Comedian',
      bikini_model: 'Bikini model',
      fashion_model: 'Fashion model',
      pop_idol: 'Pop idol',
      concafe_waitress: 'Concafe waitress',
      girls_bar_waitress: "girl's bar waitress",
      migrant_worker: 'Migrant worker',
      nightlife_business: 'Nightlife business',
      part_timer: 'Part timer',
      art_student: 'Art student',
      college_student: 'College student',
      general_student: 'General student',
      high_school_student: 'High school student',
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
      politician: '政治家',
      political_activist: '政治活動家',
      designer: 'デザイナー',
      illustrator: 'イラストレーター',
      painter: '画家',
      sculptor: '彫刻家',
      photographer: '写真家',
      manga_artist: '漫画家',
      writer: '作家',
      culinary_researcher: '料理研究家',
      comedian: 'お笑い芸人',
      bikini_model: 'グラビアモデル',
      fashion_model: 'ファッションモデル',
      pop_idol: 'ポップアイドル',
      concafe_waitress: 'コンカフェ',
      girls_bar_waitress: 'ガールズバー',
      migrant_worker: '出稼ぎ',
      nightlife_business: '夜職',
      part_timer: 'アルバイト',
      art_student: '美大生',
      college_student: '大学生',
      general_student: '一般学生',
      high_school_student: '高校生',
    }
  }

  class << self
    def select_options(user_snapshot, category)
      options = LABELS[I18n.locale].map do |_, value|
        { value: value, label: value }
      end

      options
    end

    def label_to_value(raw_label)
      LABELS.each do |_, values|
        values.each do |key, label|
          return key if raw_label == label
        end
      end
    end
  end
end

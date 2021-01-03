class JobSelector
  VALUES = %w(
    engineer
    freelancer
    influencer
    lawyer
    public_accountant
    tax_accountant
    entrepreneur
    investor
    politician
    political_activist
    designer
    illustrator
    painter
    sculptor
    photographer
    manga_artist
    writer
    bikini_model
    fashion_model
    pop_idol
    art_student
    college_student
    general_student
    high_school_student
  )

  LABELS = {
    en: {
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
      bikini_model: 'Bikini model',
      fashion_model: 'Fashion model',
      pop_idol: 'Pop idol',
      art_student: 'Art student',
      college_student: 'College student',
      general_student: 'General student',
      high_school_student: 'High school student',
    },
    ja: {
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
      bikini_model: 'グラビアモデル',
      fashion_model: 'ファッションモデル',
      pop_idol: 'ポップアイドル',
      art_student: '美大生',
      college_student: '大学生',
      general_student: '一般学生',
      high_school_student: '高校生',
    }
  }

  class << self
    def select_options(user_snapshot, category)
      labels = LABELS[I18n.locale]
      options = VALUES.map do |value|
        { value: labels[value.to_sym], label: labels[value.to_sym] }
      end

      options
    end
  end
end

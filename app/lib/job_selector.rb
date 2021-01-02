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
    designer
    artist
    bikini_model
    fashion_model
    pop_idol
    general_student
    high_school_student
    college_student
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
      designer: 'Designer',
      artist: 'Artist',
      bikini_model: 'Bikini model',
      fashion_model: 'Fashion model',
      pop_idol: 'Pop idol',
      general_student: 'General student',
      high_school_student: 'High school student',
      college_student: 'College student',
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
      designer: 'デザイナー',
      artist: 'アーティスト',
      bikini_model: 'グラビアモデル',
      fashion_model: 'ファッションモデル',
      pop_idol: 'ポップアイドル',
      general_student: '一般学生',
      high_school_student: '高校生',
      college_student: '大学生',
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

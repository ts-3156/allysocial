class JobSelector
  VALUES = %w(
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

  LABELS = {
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
end

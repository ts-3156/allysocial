class Filter
  VALUES = %w(
    active_1hour
    active_12hours
    active_3days
    active_1week
    inactive_1week
    inactive_1month
    inactive_3months
    is_protected
    is_verified
    friends_>_followers
    followers_>_friends
 )

  TRANSLATIONS = {
    en: {
      active_1hour: 'Active past 1 hour',
      active_12hours: 'Active past 12 hours',
      active_3days: 'Active past 3 days',
      active_1week: 'Active past 1 week',
      inactive_1week: 'Inactive past 1 week',
      inactive_1month: 'Inactive past 1 month',
      inactive_3months: 'Inactive past 3 months',
      is_protected: 'Protected account',
      is_verified: 'Verified account',
      'friends_>_followers': 'Friends > followers',
      'followers_>_friends': 'Friends < followers',
    },
    ja: {
      active_1hour: 'アクティブ 1時間',
      active_12hours: 'アクティブ 12時間',
      active_3days: 'アクティブ 3日間',
      active_1week: 'アクティブ 1週間',
      inactive_1week: '非アクティブ 1週間',
      inactive_1month: '非アクティブ 1ヶ月',
      inactive_3months: '非アクティブ 3ヶ月',
      is_protected: '鍵アカウント',
      is_verified: '認証済みアカウント',
      'friends_>_followers': 'フォロー数 > フォロワー数',
      'followers_>_friends': 'フォロー数 < フォロワー数',
    }
  }

  class << self
    def value_to_label(raw_key)
      TRANSLATIONS[I18n.locale].each do |key, label|
        return label if raw_key.to_sym == key
      end
      nil
    end

    def apply(query, value)
      case value
      when VALUES[0]
        query.where('status_created_at > ?', 1.hour.ago)
      when VALUES[1]
        query.where('status_created_at > ?', 12.hours.ago)
      when VALUES[2]
        query.where('status_created_at > ?', 3.days.ago)
      when VALUES[3]
        query.where('status_created_at > ?', 1.week.ago)
      when VALUES[4]
        query.where('status_created_at < ? or status_created_at is null', 1.week.ago)
      when VALUES[5]
        query.where('status_created_at < ? or status_created_at is null', 1.month.ago)
      when VALUES[6]
        query.where('status_created_at < ? or status_created_at is null', 3.months.ago)
      when VALUES[7]
        query.where(is_protected: true)
      when VALUES[8]
        query.where(is_verified: true)
      when VALUES[9]
        query.where('friends_count > followers_count')
      when VALUES[10]
        query.where('friends_count < followers_count')
      else
        query
      end
    end
  end
end

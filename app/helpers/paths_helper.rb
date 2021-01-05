module PathsHelper
  def egotter_url(user)
    "https://egotter.com/timelines/#{user}"
  end

  def twitter_url(user)
    "https://twitter.com/#{user}"
  end

  def direct_message_url(sender_uid, recipient_uid)
    "https://twitter.com/messages/#{sender_uid}-#{recipient_uid}"
  end
end

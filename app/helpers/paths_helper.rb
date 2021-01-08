module PathsHelper
  def egotter_url(user)
    "https://egotter.com/timelines/#{user}"
  end

  def twitter_url(user)
    "https://twitter.com/#{user}"
  end

  def reply_url(screen_name)
    "https://twitter.com/intent/tweet?screen_name=#{screen_name}"
  end

  def direct_message_url(sender_uid, recipient_uid)
    "https://twitter.com/messages/#{sender_uid}-#{recipient_uid}"
  end
end

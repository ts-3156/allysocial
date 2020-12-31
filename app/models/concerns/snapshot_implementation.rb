require 'active_support/concern'

module SnapshotImplementation
  extend ActiveSupport::Concern

  class_methods do
  end

  def select_users_by_job(value, options)
    if JobSelector::VALUES.include?(value)
      select_with_like_query(options) do
        TwitterUser.send(value)
      end
    else
      []
    end
  end

  def select_users_by_location(value, options)
    select_with_like_query(options) do
      TwitterUser.search_location(value)
    end
  end

  def select_users_by_url(value, options)
    select_with_like_query(options) do
      TwitterUser.search_url(value)
    end
  end

  def select_users_by_keyword(value, options)
    select_with_like_query(options) do
      TwitterUser.search_description(value)
    end
  end

  def select_with_like_query(options, &block)
    return_users = []

    api_responses.each do |response|
      uids = response.properties['uids']

      if options[:last_uid] && options[:last_uid].match?(/\A[1-9][0-9]{,30}\z/)
        next if !(index = uids.index(options[:last_uid].to_i)) || index == uids.size - 1
        uids = uids.slice((index + 1)..-1)
      end

      limit = extract_limit(options)

      uids.each_slice(100).each do |uids_array|
        remaining_limit = limit - return_users.size
        if remaining_limit <= 0
          break
        end

        users = yield.where(uid: uids_array).order_by_field(uids_array).limit(remaining_limit)
        return_users.concat(users.to_a)

        if return_users.size >= limit
          break
        end
      end

      if return_users.size >= limit
        return_users = return_users.take(limit)
        break
      end
    end

    return_users
  end

  def extract_limit(options)
    if options[:limit] && options[:limit].to_i <= 100
      options[:limit].to_i
    else
      100
    end
  end
end

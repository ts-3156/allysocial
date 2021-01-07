require 'active_support/concern'

module SnapshotImplementation
  extend ActiveSupport::Concern

  class_methods do
  end

  def search_by(type, label, options)
    case type
    when 'job'
      search_by_job(label, options)
    when 'location'
      search_by_location(label, options)
    when 'url'
      search_by_url(label, options)
    when 'keyword'
      search_by_keyword(label, options)
    else
      raise "Invalid type value=#{type}"
    end
  end

  def search_by_job(raw_value, options)
    if (value = JobSelector.label_to_value(raw_value))
      select_with_like_query(options) do
        TwitterUser.send(value)
      end
    else
      logger.info "Invalid job label value=#{raw_value}"
      []
    end
  end

  def search_by_location(value, options)
    location = Location.new(value)
    if location.tokyo?
      method_name = :tokyo
    elsif location.kanto?
      method_name = :kanto
    elsif location.japan?
      method_name = :japan
    else
      method_name = nil
    end

    select_with_like_query(options) do
      if method_name
        TwitterUser.send(method_name)
      else
        TwitterUser.search_location(value)
      end
    end
  end

  def search_by_url(value, options)
    method_name = UrlSelector.matched_value(value)

    select_with_like_query(options) do
      if method_name
        TwitterUser.send(method_name)
      else
        TwitterUser.search_url(value)
      end
    end
  end

  def search_by_keyword(value, options)
    method_name = KeywordSelector.matched_value(value)

    select_with_like_query(options) do
      if method_name
        TwitterUser.send(method_name)
      else
        TwitterUser.search_keyword(value)
      end
    end
  end

  def data_completed?
    completed_at.present?
  end

  private

  def select_with_like_query(options, &block)
    return_users = []

    users_chunks.each do |response|
      uids = response.properties['uids']

      if options[:last_uid] && options[:last_uid].match?(/\A[1-9][0-9]{1,30}\z/)
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

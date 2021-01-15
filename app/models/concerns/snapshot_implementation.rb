require 'active_support/concern'

module SnapshotImplementation
  extend ActiveSupport::Concern

  class_methods do
  end

  def update_from_user_id(user_id, users_count, api_name)
    user = User.find(user_id)
    client = user.api_client

    if user.has_subscription?(:plus)
      loop_limit = [users_count / 5000 + 1, 20].min
    else
      loop_limit = 1
    end
    remaining = client.rate_limit.send(api_name)[:remaining]

    if remaining >= loop_limit
      uids = local_fetch(client, api_name, user_snapshot.uid, loop_limit)
    else
      if user.has_subscription?(:plus)
        uids = remote_fetch(api_name, user_snapshot.uid, loop_limit)
      else
        raise "Too many loop_limit user_id=#{user_id} users_count=#{users_count} api_name=#{api_name} loop_limit=#{loop_limit} remaining=#{remaining}"
      end
    end

    uids.each_slice(5000) do |uids_array|
      users_chunks.create!(uids: uids_array)
    end

    uids.each_slice(100) do |uids_array|
      CreateTwitterUsersWorker.perform_async(user_id, uids_array)
    end

    update(completed_at: Time.zone.now)
  end

  def local_fetch(client, api_name, uid, loop_limit)
    client.send(api_name, uid, loop_limit: loop_limit)
  rescue => e
    if TwitterApiStatus.too_many_requests?(e)
      remote_fetch(api_name, uid, loop_limit)
    else
      raise
    end
  end

  def remote_fetch(api_name, uid, loop_limit)
    EgotterClient.new.send(api_name, uid, loop_limit: loop_limit)
  end
end

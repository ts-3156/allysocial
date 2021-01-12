require 'active_support/concern'

module SnapshotImplementation
  extend ActiveSupport::Concern

  class_methods do
  end

  def update_from_user_id(user_id, api_name)
    begin
      client = User.find(user_id).api_client
      uids = client.send(api_name, user_snapshot.uid, loop_limit: 1)
    rescue => e
      if TwitterApiStatus.too_many_requests?(e)
        uids = EgotterClient.new.send(api_name, user_snapshot.uid, loop_limit: 1)
      else
        raise
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

end

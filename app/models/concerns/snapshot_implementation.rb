require 'active_support/concern'

module SnapshotImplementation
  extend ActiveSupport::Concern

  class_methods do
  end

  def update_from_user_id(user_id, users_count, api_name)
    # TODO Check subscription

    if users_count <= 5000
      client = User.find(user_id).api_client
      uids = client.send(api_name, user_snapshot.uid)
    else
      uids = EgotterClient.new.send(api_name, user_snapshot.uid) # TODO Set loop_limit
    end

    uids.each_slice(5000) do |uids_array|
      users_chunks.create!(properties: { uids: uids_array })
    end

    uids.each_slice(100) do |uids_array|
      CreateTwitterUsersWorker.perform_async(user_id, uids_array)
    end

    update(completed_at: Time.zone.now)
  end

end

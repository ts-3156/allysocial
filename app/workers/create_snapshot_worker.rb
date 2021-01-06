class CreateSnapshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0, backtrace: false

  def perform(user_id, user_snapshot_id, options = {})
    user_snapshot = UserSnapshot.find(user_snapshot_id)
    create_snapshot(user_id, user_snapshot)
  rescue => e
    if e.message.include?('Mysql2::Error: Duplicate entry')
      # ActiveRecord::RecordNotUnique
    else
      logger.warn "Unhandled exception: #{e.inspect}"
      logger.info e.backtrace.join("\n")
    end
  end
end

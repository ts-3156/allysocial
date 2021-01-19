class CreateFollowersChunks < ActiveRecord::Migration[6.1]
  def change
    create_table :followers_chunks do |t|
      t.bigint :followers_snapshot_id, null: false
      t.json :uids

      t.timestamps null: false

      t.index :followers_snapshot_id
      t.index :created_at
    end
  end
end

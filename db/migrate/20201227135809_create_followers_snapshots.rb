class CreateFollowersSnapshots < ActiveRecord::Migration[6.1]
  def change
    create_table :followers_snapshots do |t|
      t.bigint :user_snapshot_id, null: false
      t.json :properties
      t.datetime :completed_at

      t.timestamps null: false

      t.index :user_snapshot_id, unique: true
      t.index :created_at
    end
  end
end

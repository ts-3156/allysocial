class CreateMutualFriendsChunks < ActiveRecord::Migration[6.1]
  def change
    create_table :mutual_friends_chunks do |t|
      t.bigint :mutual_friends_snapshot_id, null: false
      t.json :uids

      t.timestamps null: false

      t.index :mutual_friends_snapshot_id
      t.index :created_at
    end
  end
end

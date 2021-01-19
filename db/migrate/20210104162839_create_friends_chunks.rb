class CreateFriendsChunks < ActiveRecord::Migration[6.1]
  def change
    create_table :friends_chunks do |t|
      t.bigint :friends_snapshot_id, null: false
      t.json :uids

      t.timestamps null: false

      t.index :friends_snapshot_id
      t.index :created_at
    end
  end
end

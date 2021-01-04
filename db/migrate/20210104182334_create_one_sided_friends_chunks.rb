class CreateOneSidedFriendsChunks < ActiveRecord::Migration[6.1]
  def change
    create_table :one_sided_friends_chunks do |t|
      t.bigint :one_sided_friends_snapshot_id, null: false
      t.json :properties

      t.timestamps null: false

      t.index :one_sided_friends_snapshot_id
      t.index :created_at
    end
  end
end

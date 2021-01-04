class CreateOneSidedFollowersChunks < ActiveRecord::Migration[6.1]
  def change
    create_table :one_sided_followers_chunks do |t|
      t.bigint :one_sided_followers_snapshot_id, null: false
      t.json :properties

      t.timestamps null: false

      t.index :one_sided_followers_snapshot_id, name: :index_one_sided_followers_chunks_on_snapshot_id
      t.index :created_at
    end
  end
end

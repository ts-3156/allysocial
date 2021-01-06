class CreateFollowersInsights < ActiveRecord::Migration[6.1]
  def change
    create_table :followers_insights do |t|
      t.bigint :user_snapshot_id, null: false
      t.json :job
      t.json :description
      t.json :location
      t.json :url
      t.datetime :completed_at

      t.timestamps null: false

      t.index :user_snapshot_id, unique: true
      t.index :created_at
    end
  end
end

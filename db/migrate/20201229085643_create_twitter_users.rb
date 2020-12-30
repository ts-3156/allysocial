class CreateTwitterUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_users do |t|
      t.bigint :uid, null: false
      t.string :screen_name, null: false
      t.string :name, null: false
      t.integer :statuses_count, null: false
      t.integer :friends_count, null: false
      t.integer :followers_count, null: false
      t.text :description
      t.string :location
      t.string :url
      t.string :profile_image_url
      t.string :profile_banner_url
      t.datetime :account_created_at

      t.timestamps null: false

      t.index :uid, unique: true
      t.index :created_at
    end
  end
end

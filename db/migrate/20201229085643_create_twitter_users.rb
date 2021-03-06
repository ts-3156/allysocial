class CreateTwitterUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_users do |t|
      t.bigint :uid, null: false
      t.string :screen_name, null: false
      t.string :name, null: false
      t.integer :statuses_count, null: false
      t.integer :friends_count, null: false
      t.integer :followers_count, null: false
      t.integer :listed_count
      t.integer :favourites_count
      t.boolean :is_protected
      t.boolean :is_verified
      t.text :description
      t.string :location
      t.text :url
      t.string :profile_image_url
      t.string :profile_banner_url
      t.datetime :account_created_at
      t.bigint :status_id
      t.text :status_text
      t.integer :status_retweet_count
      t.integer :status_favorite_count
      t.json :status_photo_urls
      t.datetime :status_created_at

      t.timestamps null: false

      t.index :uid, unique: true
      t.index :created_at
    end
  end
end

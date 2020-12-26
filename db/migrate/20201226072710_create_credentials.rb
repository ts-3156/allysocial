class CreateCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :credentials do |t|
      t.bigint :user_id, null: false
      t.boolean :authorized, null: false
      t.text :access_token, null: false
      t.text :access_secret, null: false

      t.timestamps null: false

      t.index :user_id, unique: true
      t.index :created_at
    end
  end
end

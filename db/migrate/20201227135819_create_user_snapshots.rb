class CreateUserSnapshots < ActiveRecord::Migration[6.1]
  def change
    create_table :user_snapshots do |t|
      t.bigint :uid, null: false
      t.json :properties

      t.timestamps null: false

      t.index :uid
      t.index :created_at
    end
  end
end

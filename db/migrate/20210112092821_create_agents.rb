class CreateAgents < ActiveRecord::Migration[6.1]
  def change
    create_table :agents do |t|
      t.bigint :user_id, null: false

      t.timestamps null: false

      t.index :user_id, unique: true
      t.index :created_at
    end
  end
end

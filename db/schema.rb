# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_30_090246) do

  create_table "credentials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "authorized", null: false
    t.text "access_token", null: false
    t.text "access_secret", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_credentials_on_created_at"
    t.index ["user_id"], name: "index_credentials_on_user_id", unique: true
  end

  create_table "followers_insights", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.json "description_keywords"
    t.json "location_keywords"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_followers_insights_on_created_at"
    t.index ["user_snapshot_id"], name: "index_followers_insights_on_user_snapshot_id", unique: true
  end

  create_table "followers_responses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "followers_snapshot_id", null: false
    t.bigint "previous_cursor"
    t.bigint "next_cursor"
    t.json "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_followers_responses_on_created_at"
    t.index ["followers_snapshot_id"], name: "index_followers_responses_on_followers_snapshot_id"
  end

  create_table "followers_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.json "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_followers_snapshots_on_created_at"
    t.index ["user_snapshot_id"], name: "index_followers_snapshots_on_user_snapshot_id", unique: true
  end

  create_table "friends_insights", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.json "description_keywords"
    t.json "location_keywords"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_friends_insights_on_created_at"
    t.index ["user_snapshot_id"], name: "index_friends_insights_on_user_snapshot_id", unique: true
  end

  create_table "friends_responses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "friends_snapshot_id", null: false
    t.bigint "previous_cursor"
    t.bigint "next_cursor"
    t.json "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_friends_responses_on_created_at"
    t.index ["friends_snapshot_id"], name: "index_friends_responses_on_friends_snapshot_id"
  end

  create_table "friends_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.json "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_friends_snapshots_on_created_at"
    t.index ["user_snapshot_id"], name: "index_friends_snapshots_on_user_snapshot_id", unique: true
  end

  create_table "twitter_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "uid", null: false
    t.string "screen_name", null: false
    t.string "name", null: false
    t.integer "statuses_count", null: false
    t.integer "friends_count", null: false
    t.integer "followers_count", null: false
    t.text "description"
    t.string "location"
    t.string "url"
    t.string "profile_image_url"
    t.string "profile_banner_url"
    t.datetime "account_created_at"
    t.bigint "status_id"
    t.text "status_text"
    t.datetime "status_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_twitter_users_on_created_at"
    t.index ["uid"], name: "index_twitter_users_on_uid", unique: true
  end

  create_table "user_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "uid", null: false
    t.json "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_user_snapshots_on_created_at"
    t.index ["uid"], name: "index_user_snapshots_on_uid"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "uid", null: false
    t.string "screen_name", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
